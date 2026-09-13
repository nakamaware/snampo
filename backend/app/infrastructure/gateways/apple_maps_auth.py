"""Apple Maps Server API の JWT / access token 管理

認証フロー:
1. Team ID + Key ID + .p8/PEM で ES256 JWT (maps_auth_token) を署名
2. GET /v1/token で短い access token に交換
3. 有効期限までキャッシュして再利用

秘密鍵は Cloud Run では APPLE_MAPS_PRIVATE_KEY (PEM 文字列)、
ローカルでは APPLE_MAPS_PRIVATE_KEY_PATH (.p8 ファイル) を優先順で読む。
PEM / token はログに出さない。

参考:
https://developer.apple.com/documentation/applemapsserverapi/creating-and-using-tokens-with-maps-server-api
https://developer.apple.com/documentation/applemapsserverapi/-v1-token
"""

from __future__ import annotations

import logging
import time
from pathlib import Path
from typing import cast

import jwt
import requests
from requests.exceptions import RequestException, Timeout

from app.config import REQUEST_TIMEOUT_SECONDS
from app.domain.exceptions import ExternalServiceError, ExternalServiceTimeoutError

logger = logging.getLogger(__name__)

APPLE_MAPS_BASE_URL = "https://maps-api.apple.com/v1"
# maps_auth_token (自前署名 JWT) の寿命。access token は別途 expiresInSeconds で管理する。
MAPS_AUTH_TOKEN_TTL_SECONDS = 3600
# access token 更新の安全マージン (秒)
ACCESS_TOKEN_EXPIRY_SKEW_SECONDS = 60
SERVICE_NAME = "Apple Maps Server API"


class AppleMapsCredentialsError(ValueError):
    """Apple Maps 認証に必要な環境変数 / 秘密鍵が不足している"""


class AppleMapsTokenProvider:
    """Maps Server API 用 access token の発行とキャッシュ"""

    def __init__(
        self,
        team_id: str,
        key_id: str,
        private_key_pem: str,
        *,
        base_url: str = APPLE_MAPS_BASE_URL,
        session: requests.Session | None = None,
    ) -> None:
        """初期化

        Args:
            team_id: Apple Developer Team ID (10 文字)
            key_id: Maps 用秘密鍵の Key ID (10 文字)
            private_key_pem: .p8 秘密鍵の PEM 文字列
            base_url: API ベース URL (テスト差し替え用)
            session: requests.Session (テスト差し替え用)
        """
        self._team_id = team_id
        self._key_id = key_id
        self._private_key_pem = private_key_pem
        self._base_url = base_url.rstrip("/")
        self._session = session or requests.Session()
        self._access_token: str | None = None
        self._access_token_expires_at: float = 0.0

    @classmethod
    def from_config(cls) -> AppleMapsTokenProvider:
        """app.config の環境変数から Provider を構築する。"""
        from app.config import (
            APPLE_MAPS_KEY_ID,
            APPLE_MAPS_PRIVATE_KEY,
            APPLE_MAPS_PRIVATE_KEY_PATH,
            APPLE_TEAM_ID,
        )

        return cls.from_env(
            team_id=APPLE_TEAM_ID,
            key_id=APPLE_MAPS_KEY_ID,
            private_key_pem=APPLE_MAPS_PRIVATE_KEY,
            private_key_path=APPLE_MAPS_PRIVATE_KEY_PATH,
        )

    @classmethod
    def from_env(
        cls,
        *,
        team_id: str | None,
        key_id: str | None,
        private_key_pem: str | None = None,
        private_key_path: str | None = None,
        backend_dir: Path | None = None,
        base_url: str = APPLE_MAPS_BASE_URL,
        session: requests.Session | None = None,
    ) -> AppleMapsTokenProvider:
        """環境変数相当の値から Provider を構築する。

        秘密鍵は APPLE_MAPS_PRIVATE_KEY (PEM) を優先し、無ければ
        APPLE_MAPS_PRIVATE_KEY_PATH (.p8) を読む。

        Args:
            team_id: APPLE_TEAM_ID
            key_id: APPLE_MAPS_KEY_ID
            private_key_pem: APPLE_MAPS_PRIVATE_KEY (PEM 文字列)
            private_key_path: APPLE_MAPS_PRIVATE_KEY_PATH (.p8 パス)
            backend_dir: 相対パス解決の基準 (未指定なら CWD)
            base_url: API ベース URL
            session: requests.Session

        Returns:
            AppleMapsTokenProvider

        Raises:
            AppleMapsCredentialsError: 必須値が欠けている / 鍵が読めない場合
        """
        missing_ids = [
            name
            for name, value in (
                ("APPLE_TEAM_ID", team_id),
                ("APPLE_MAPS_KEY_ID", key_id),
            )
            if not (value and value.strip())
        ]
        if missing_ids:
            raise AppleMapsCredentialsError(
                "Apple Maps Server API の認証情報が不足しています: "
                + ", ".join(missing_ids)
                + "。backend/.env.example を参照して設定してください。"
            )

        pem = (private_key_pem or "").strip()
        if not pem:
            path_value = (private_key_path or "").strip()
            if not path_value:
                raise AppleMapsCredentialsError(
                    "Apple Maps Server API の秘密鍵が不足しています: "
                    "APPLE_MAPS_PRIVATE_KEY または APPLE_MAPS_PRIVATE_KEY_PATH を設定してください。"
                )
            key_path = Path(path_value).expanduser()
            if not key_path.is_absolute():
                root = backend_dir if backend_dir is not None else Path.cwd()
                key_path = root / key_path
            if not key_path.is_file():
                raise AppleMapsCredentialsError(f"秘密鍵ファイルが見つかりません: {key_path}")
            pem = key_path.read_text(encoding="utf-8").strip()

        if "PRIVATE KEY" not in pem:
            raise AppleMapsCredentialsError(
                "APPLE_MAPS_PRIVATE_KEY / 鍵ファイルの内容が PEM 形式ではありません。"
            )

        return cls(
            team_id=cast(str, team_id).strip(),
            key_id=cast(str, key_id).strip(),
            private_key_pem=pem,
            base_url=base_url,
            session=session,
        )

    def create_maps_auth_token(self, *, now: float | None = None) -> str:
        """ES256 で maps_auth_token (JWT) を署名する。

        Args:
            now: 現在時刻 (UNIX 秒)。テスト差し替え用。

        Returns:
            str: 署名済み JWT
        """
        issued_at = int(time.time() if now is None else now)
        headers = {
            "alg": "ES256",
            "kid": self._key_id,
            "typ": "JWT",
        }
        payload = {
            "iss": self._team_id,
            "iat": issued_at,
            "exp": issued_at + MAPS_AUTH_TOKEN_TTL_SECONDS,
            "scope": "server_api",
        }
        return jwt.encode(payload, self._private_key_pem, algorithm="ES256", headers=headers)

    def get_access_token(self, *, force_refresh: bool = False, now: float | None = None) -> str:
        """有効な access token を返す (期限までキャッシュ)。

        Args:
            force_refresh: True ならキャッシュを無視して再取得
            now: 現在時刻 (UNIX 秒)。テスト差し替え用。

        Returns:
            str: Bearer に載せる access token

        Raises:
            ExternalServiceError: /v1/token 呼び出し失敗
            ExternalServiceTimeoutError: タイムアウト
        """
        current = time.time() if now is None else now
        if (
            not force_refresh
            and self._access_token is not None
            and current < self._access_token_expires_at - ACCESS_TOKEN_EXPIRY_SKEW_SECONDS
        ):
            return self._access_token

        maps_auth_token = self.create_maps_auth_token(now=current)
        url = f"{self._base_url}/token"
        try:
            response = self._session.get(
                url,
                headers={"Authorization": f"Bearer {maps_auth_token}"},
                timeout=REQUEST_TIMEOUT_SECONDS,
            )
            response.raise_for_status()
            data = response.json()
        except Timeout as error:
            logger.error("Timeout while exchanging Apple Maps access token.")
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to exchange Apple Maps access token",
                service_name=SERVICE_NAME,
            ) from error
        except RequestException as error:
            logger.error("Failed to exchange Apple Maps access token: %s", error)
            raise ExternalServiceError(
                f"Failed to exchange Apple Maps access token: {error}",
                service_name=SERVICE_NAME,
            ) from error

        access_token = data.get("accessToken")
        if not access_token or not isinstance(access_token, str):
            keys = sorted(data.keys()) if isinstance(data, dict) else []
            raise ExternalServiceError(
                f"Apple Maps /v1/token response missing accessToken (keys={keys})",
                service_name=SERVICE_NAME,
            )

        expires_in = data.get("expiresInSeconds", 1800)
        try:
            expires_in_seconds = float(expires_in)
        except (TypeError, ValueError):
            expires_in_seconds = 1800.0

        self._access_token = access_token
        self._access_token_expires_at = current + expires_in_seconds
        return access_token
