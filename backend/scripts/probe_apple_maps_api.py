#!/usr/bin/env python3
"""Apple Maps Server API をローカルから疎通確認するスクリプト。

使い方:
  cd backend
  uv run python scripts/probe_apple_maps_api.py

必要な環境変数 (.env に設定):
  APPLE_TEAM_ID              Apple Developer の Team ID (10文字)
  APPLE_MAPS_KEY_ID          Maps 用秘密鍵の Key ID (10文字)
  APPLE_MAPS_PRIVATE_KEY_PATH  ダウンロードした .p8 ファイルのパス
"""

from __future__ import annotations

import json
import os
import sys
import time
from pathlib import Path

import jwt
import requests
from dotenv import load_dotenv

APPLE_MAPS_BASE_URL = "https://maps-api.apple.com/v1"
REQUEST_TIMEOUT_SECONDS = 15


def _backend_dir() -> Path:
    return Path(__file__).resolve().parent.parent


def _load_env() -> None:
    load_dotenv(_backend_dir() / ".env")


def _require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise ValueError(f"{name} が未設定です。backend/.env を確認してください。")
    return value


def _load_private_key() -> str:
    key_path = Path(_require_env("APPLE_MAPS_PRIVATE_KEY_PATH")).expanduser()
    if not key_path.is_absolute():
        key_path = _backend_dir() / key_path
    if not key_path.is_file():
        raise ValueError(f"秘密鍵ファイルが見つかりません: {key_path}")
    return key_path.read_text(encoding="utf-8")


def create_maps_auth_token() -> str:
    """Maps Server API 用の署名済み JWT (maps_auth_token) を生成する。"""
    team_id = _require_env("APPLE_TEAM_ID")
    key_id = _require_env("APPLE_MAPS_KEY_ID")
    private_key = _load_private_key()
    now = int(time.time())

    headers = {
        "alg": "ES256",
        "kid": key_id,
        "typ": "JWT",
    }
    payload = {
        "iss": team_id,
        "iat": now,
        "exp": now + 3600,
        "scope": "server_api",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)


def exchange_access_token(maps_auth_token: str) -> str:
    """署名済み JWT を access token に交換する。"""
    response = requests.get(
        f"{APPLE_MAPS_BASE_URL}/token",
        headers={"Authorization": f"Bearer {maps_auth_token}"},
        timeout=REQUEST_TIMEOUT_SECONDS,
    )
    if not response.ok:
        raise RuntimeError(
            f"/v1/token が失敗しました: HTTP {response.status_code}\n{response.text}"
        )

    data = response.json()
    access_token = data.get("accessToken")
    if not access_token:
        raise RuntimeError(f"accessToken がレスポンスにありません: {data}")
    return access_token


def call_directions(access_token: str) -> dict:
    """東京駅 → 皇居外苑の徒歩ルートを取得する。"""
    params = {
        "origin": "35.681236,139.767125",
        "destination": "35.685175,139.752799",
        "transportType": "WALKING",
    }
    response = requests.get(
        f"{APPLE_MAPS_BASE_URL}/directions",
        headers={"Authorization": f"Bearer {access_token}"},
        params=params,
        timeout=REQUEST_TIMEOUT_SECONDS,
    )
    if not response.ok:
        raise RuntimeError(
            f"/v1/directions が失敗しました: HTTP {response.status_code}\n{response.text}"
        )
    return response.json()


def call_search(access_token: str) -> dict:
    """皇居周辺の公園を検索する。"""
    params = {
        "q": "皇居 公園",
        "searchLocation": "35.685175,139.752799",
        "limit": 3,
    }
    response = requests.get(
        f"{APPLE_MAPS_BASE_URL}/search",
        headers={"Authorization": f"Bearer {access_token}"},
        params=params,
        timeout=REQUEST_TIMEOUT_SECONDS,
    )
    if not response.ok:
        raise RuntimeError(
            f"/v1/search が失敗しました: HTTP {response.status_code}\n{response.text}"
        )
    return response.json()


def _summarize_directions(data: dict) -> str:
    routes = data.get("routes", [])
    if not routes:
        return "routes が空です"
    first = routes[0]
    return (
        f"routes={len(routes)}, "
        f"first.distanceMeters={first.get('distanceMeters')}, "
        f"first.durationSeconds={first.get('durationSeconds')}, "
        f"transportType={first.get('transportType')}"
    )


def _summarize_search(data: dict) -> str:
    results = data.get("results", [])
    if not results:
        return "results が空です"
    names = [item.get("name", "(no name)") for item in results[:3]]
    return f"results={len(results)}, names={names}"


def main() -> int:
    """Apple Maps Server API の疎通確認を実行する。"""
    _load_env()

    print("1/4 JWT (maps_auth_token) を生成中...")
    maps_auth_token = create_maps_auth_token()
    print("   OK")

    print("2/4 /v1/token で access token を取得中...")
    access_token = exchange_access_token(maps_auth_token)
    print("   OK")

    print("3/4 /v1/directions を呼び出し中...")
    directions = call_directions(access_token)
    print(f"   OK: {_summarize_directions(directions)}")

    print("4/4 /v1/search を呼び出し中...")
    search = call_search(access_token)
    print(f"   OK: {_summarize_search(search)}")

    print(
        "\n疎通確認に成功しました。"
        "レスポンス全文は backend/apple_maps_probe_result.json に保存します。"
    )
    output_path = _backend_dir() / "apple_maps_probe_result.json"
    output_path.write_text(
        json.dumps({"directions": directions, "search": search}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, RuntimeError, requests.RequestException) as error:
        print(f"\nエラー: {error}", file=sys.stderr)
        raise SystemExit(1) from error
