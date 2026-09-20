from __future__ import annotations

import math
from pathlib import Path
from unittest.mock import MagicMock

import jwt
import pytest
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from requests.exceptions import HTTPError

from app.application.gateway_interfaces.apple_maps_gateway import (
    AppleSearchHit,
    is_apple_place_id,
    prefix_apple_place_id,
)
from app.application.gateway_interfaces.apple_poi_genre import apple_poi_category_to_genre
from app.domain.exceptions import ExternalServiceError
from app.domain.value_objects import Coordinate
from app.infrastructure.gateways.apple_maps_auth import (
    AppleMapsCredentialsError,
    AppleMapsTokenProvider,
)
from app.infrastructure.gateways.apple_maps_gateway_impl import (
    CASUAL_QUERY_BUCKET,
    CULTURE_QUERY_BUCKET,
    OUTDOOR_QUERY_BUCKET,
    AppleMapsGatewayImpl,
    AppleMapsHTTPError,
    build_stratified_query_bag,
    circle_to_search_region,
    distance_band_bounds,
    format_search_region,
    stable_search_seed,
)


def _generate_es256_private_key_pem() -> str:
    private_key = ec.generate_private_key(ec.SECP256R1())
    pem = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
    return pem.decode("utf-8")


@pytest.fixture
def es256_pem() -> str:
    """ES256 用の一時秘密鍵 PEM。"""
    return _generate_es256_private_key_pem()


@pytest.fixture
def token_provider(es256_pem: str) -> AppleMapsTokenProvider:
    """モック Session 付き TokenProvider。"""
    session = MagicMock()
    return AppleMapsTokenProvider(
        team_id="TEAM12ABCD",
        key_id="KEY12ABCDE",
        private_key_pem=es256_pem,
        base_url="https://maps-api.apple.test/v1",
        session=session,
    )


class TestApplePoiCategoryToGenre:
    """Apple PoiCategory → フロント用ジャンルキー"""

    def test_既知カテゴリはGoogle系キーになること(self) -> None:
        """Park / ReligiousSite などを snake_case に固定する。"""
        assert apple_poi_category_to_genre("Park") == "park"
        assert apple_poi_category_to_genre("ReligiousSite") == "religious_site"
        assert apple_poi_category_to_genre("Cafe") == "cafe"

    def test_未知のPascalCaseは機械変換すること(self) -> None:
        """マップに無いカテゴリは snake_case へ落とす。"""
        assert apple_poi_category_to_genre("ScenicLookout") == "scenic_lookout"

    def test_空はNoneのままであること(self) -> None:
        """カテゴリ無しは Landmark.primary_type も無し。"""
        assert apple_poi_category_to_genre(None) is None
        assert apple_poi_category_to_genre("") is None

    def test_to_landmarkがジャンルを正規化すること(self) -> None:
        """VO 変換後の primary_type はフロントが読めるキーになる。"""
        hit = AppleSearchHit(
            place_id="apple:1",
            display_name="箱根神社",
            coordinate=Coordinate(latitude=35.2, longitude=139.1),
            distance_m=2000.0,
            source="query",
            poi_category="ReligiousSite",
        )
        landmark = hit.to_landmark()
        assert landmark.primary_type == "religious_site"
        assert landmark.types == ["religious_site"]


class TestBboxAndDistanceBand:
    """bbox 近似と距離帯"""

    def test_円をsearchRegionのbboxに近似できること(self) -> None:
        """center+radius が north,east,south,west になる。"""
        center = Coordinate(latitude=35.0, longitude=139.0)
        north, east, south, west = circle_to_search_region(center, 1000.0)
        assert north > 35.0 > south
        assert east > 139.0 > west
        assert format_search_region((north, east, south, west)).count(",") == 3

    def test_距離帯の上下限がtoleranceどおりであること(self) -> None:
        """±15% の距離帯を計算できる。"""
        low, high = distance_band_bounds(2000.0, 15.0)
        assert low == pytest.approx(1700.0)
        assert high == pytest.approx(2300.0)

    def test_place_idにappleプレフィックスが付くこと(self) -> None:
        """Google place_id と衝突しないよう prefix する。"""
        assert prefix_apple_place_id("I123") == "apple:I123"
        assert prefix_apple_place_id("apple:I123") == "apple:I123"
        assert is_apple_place_id("apple:I123")
        assert not is_apple_place_id("ChIJXSModoWLGGARILWiCfeu2M0")


class TestStratifiedQueryBag:
    """層別クエリバッグ"""

    def test_固定シードで先頭3件が各バケットから1つであること(self) -> None:
        """outdoor / culture / casual から 1 件ずつが先頭に並ぶ。"""
        bag = build_stratified_query_bag(42)
        assert bag[0] in OUTDOOR_QUERY_BUCKET
        assert bag[1] in CULTURE_QUERY_BUCKET
        assert bag[2] in CASUAL_QUERY_BUCKET

    def test_同一シードは同一順序であること(self) -> None:
        """再現可能なシャッフルになる。"""
        assert build_stratified_query_bag(99) == build_stratified_query_bag(99)

    def test_中心と半径から安定シードが得られること(self) -> None:
        """同じ中心・半径なら同じシード。"""
        center = Coordinate(latitude=35.232, longitude=139.107)
        assert stable_search_seed(center, 2000) == stable_search_seed(center, 2000)
        assert stable_search_seed(center, 2000) != stable_search_seed(center, 2500)


class TestAppleMapsTokenProvider:
    """JWT / access token"""

    def test_maps_auth_tokenがES256で署名されること(
        self, token_provider: AppleMapsTokenProvider, es256_pem: str
    ) -> None:
        """maps_auth_token の header / claims / 署名を検証する。"""
        token = token_provider.create_maps_auth_token(now=1_700_000_000)
        header = jwt.get_unverified_header(token)
        assert header["alg"] == "ES256"
        assert header["kid"] == "KEY12ABCDE"
        claims = jwt.decode(token, options={"verify_signature": False})
        assert claims["iss"] == "TEAM12ABCD"
        assert claims["scope"] == "server_api"
        private_key = load_pem_private_key(es256_pem.encode(), password=None)
        public_key = private_key.public_key()
        jwt.decode(
            token,
            public_key,
            algorithms=["ES256"],
            options={"verify_exp": False},
        )

    def test_access_tokenをキャッシュして再取得しないこと(
        self, token_provider: AppleMapsTokenProvider
    ) -> None:
        """有効期限内は /v1/token を再呼び出ししない。"""
        mock_response = MagicMock()
        mock_response.raise_for_status = MagicMock()
        mock_response.json.return_value = {
            "accessToken": "access-token-1",
            "expiresInSeconds": 1800,
        }
        token_provider._session.get.return_value = mock_response

        first = token_provider.get_access_token(now=1_000.0)
        second = token_provider.get_access_token(now=1_100.0)
        assert first == second == "access-token-1"
        assert token_provider._session.get.call_count == 1

    def test_期限切れ後はaccess_tokenを再取得すること(
        self, token_provider: AppleMapsTokenProvider
    ) -> None:
        """skew を超えたら access token を更新する。"""
        first_response = MagicMock()
        first_response.raise_for_status = MagicMock()
        first_response.json.return_value = {
            "accessToken": "token-a",
            "expiresInSeconds": 100,
        }
        second_response = MagicMock()
        second_response.raise_for_status = MagicMock()
        second_response.json.return_value = {
            "accessToken": "token-b",
            "expiresInSeconds": 1800,
        }
        token_provider._session.get.side_effect = [first_response, second_response]

        assert token_provider.get_access_token(now=0.0) == "token-a"
        assert token_provider.get_access_token(now=50.0) == "token-b"
        assert token_provider._session.get.call_count == 2

    def test_PEM環境変数からProviderを構築できること(self, es256_pem: str) -> None:
        """APPLE_MAPS_PRIVATE_KEY (PEM) を優先して読める。"""
        provider = AppleMapsTokenProvider.from_env(
            team_id="TEAM12ABCD",
            key_id="KEY12ABCDE",
            private_key_pem=es256_pem,
            private_key_path=None,
        )
        token = provider.create_maps_auth_token(now=1_700_000_000)
        assert isinstance(token, str)
        assert token.count(".") == 2

    def test_PEMが無くパスがあればファイルから読むこと(
        self, es256_pem: str, tmp_path: Path
    ) -> None:
        """APPLE_MAPS_PRIVATE_KEY_PATH フォールバック。"""
        key_file = tmp_path / "AuthKey_TEST.p8"
        key_file.write_text(es256_pem, encoding="utf-8")
        provider = AppleMapsTokenProvider.from_env(
            team_id="TEAM12ABCD",
            key_id="KEY12ABCDE",
            private_key_pem=None,
            private_key_path=str(key_file),
            backend_dir=tmp_path,
        )
        assert provider.create_maps_auth_token(now=1_700_000_000)

    def test_認証情報不足でCredentialsErrorになること(self, tmp_path: Path) -> None:
        """必須 env が無いとき明確なエラーになる。"""
        with pytest.raises(AppleMapsCredentialsError, match="APPLE_TEAM_ID"):
            AppleMapsTokenProvider.from_env(
                team_id=None,
                key_id="KEY",
                private_key_pem="-----BEGIN PRIVATE KEY-----\nX\n-----END PRIVATE KEY-----",
                backend_dir=tmp_path,
            )

    def test_秘密鍵が無いとCredentialsErrorになること(self) -> None:
        """PEM もパスも無いときエラーになる。"""
        with pytest.raises(AppleMapsCredentialsError, match="APPLE_MAPS_PRIVATE_KEY"):
            AppleMapsTokenProvider.from_env(
                team_id="TEAM12ABCD",
                key_id="KEY12ABCDE",
                private_key_pem=None,
                private_key_path=None,
            )

    def test_accessToken欠落時はキー名のみ例外に含めること(
        self, token_provider: AppleMapsTokenProvider
    ) -> None:
        """トークン JSON の値はログに載せない (キー一覧のみ)。"""
        mock_response = MagicMock()
        mock_response.raise_for_status = MagicMock()
        mock_response.json.return_value = {
            "expiresInSeconds": 1800,
            "unexpectedSecret": "should-not-appear-in-message",
        }
        token_provider._session.get.return_value = mock_response

        with pytest.raises(ExternalServiceError) as exc_info:
            token_provider.get_access_token(now=1_000.0)
        assert "accessToken" in exc_info.value.message
        assert "keys=" in exc_info.value.message
        assert "unexpectedSecret" in exc_info.value.message
        assert "should-not-appear-in-message" not in exc_info.value.message


class TestAppleMapsGatewaySearch:
    """層別クエリ / 早期停止 / ファンアウト / dedup"""

    @pytest.fixture
    def gateway(self, token_provider: AppleMapsTokenProvider) -> AppleMapsGatewayImpl:
        """アクセストークン取得済みの Gateway。"""
        mock_response = MagicMock()
        mock_response.raise_for_status = MagicMock()
        mock_response.json.return_value = {
            "accessToken": "test-access",
            "expiresInSeconds": 1800,
        }
        token_provider._session.get.return_value = mock_response
        return AppleMapsGatewayImpl(
            token_provider,
            base_url="https://maps-api.apple.test/v1",
            session=MagicMock(),
        )

    def _point_at_distance(
        self, center: Coordinate, distance_m: float, bearing_deg: float = 0.0
    ) -> Coordinate:
        delta_lat = distance_m / 111_320.0
        radians = math.radians(bearing_deg)
        lat = float(center.latitude) + delta_lat * math.cos(radians)
        meters_per_degree_lng = 111_320.0 * math.cos(math.radians(float(center.latitude)))
        lng = float(center.longitude) + (distance_m / meters_per_degree_lng) * math.sin(radians)
        return Coordinate(latitude=lat, longitude=lng)

    def _poi_response(self, place_id: str, name: str, coordinate: Coordinate) -> MagicMock:
        response = MagicMock()
        response.raise_for_status = MagicMock()
        response.json.return_value = {
            "results": [
                {
                    "id": place_id,
                    "name": name,
                    "poiCategory": "Park",
                    "coordinate": {
                        "latitude": coordinate.latitude,
                        "longitude": coordinate.longitude,
                    },
                }
            ]
        }
        return response

    def test_クエリ検索はsearchRegionのみでsearchLocationを付けないこと(
        self, gateway: AppleMapsGatewayImpl
    ) -> None:
        """本番クエリフェーズのパラメータ制約。"""
        center = Coordinate(latitude=35.232, longitude=139.107)
        in_band = self._point_at_distance(center, 2000.0)
        gateway._session.get.return_value = self._poi_response("park-1", "箱根公園", in_band)

        hits = gateway.search_landmarks_nearby(
            center, 2000, target_count=1, distance_tolerance_percent=15.0, max_calls=1
        )
        assert len(hits) == 1
        assert hits[0].source == "query"
        params = gateway._session.get.call_args.kwargs["params"]
        assert "q" in params
        assert "searchRegion" in params
        assert "searchLocation" not in params
        assert params["resultTypeFilter"] == "Poi"
        assert params["lang"] == "ja-JP"
        assert params["limitToCountries"] == "JP"

    def test_目標件数到達で早期停止すること(self, gateway: AppleMapsGatewayImpl) -> None:
        """target_count に達したら残クエリを呼ばない。"""
        center = Coordinate(latitude=35.232, longitude=139.107)
        in_band = self._point_at_distance(center, 2000.0)
        gateway._session.get.return_value = self._poi_response("park-1", "箱根公園", in_band)

        hits = gateway.search_landmarks_nearby(
            center, 2000, target_count=1, distance_tolerance_percent=15.0, max_calls=8
        )
        assert len(hits) == 1
        assert gateway._session.get.call_count == 1

    def test_件数不足時にファンアウトでsearchLocationのみ使うこと(
        self, gateway: AppleMapsGatewayImpl
    ) -> None:
        """クエリで 0 件のあと、円周ファンアウトが searchLocation のみ送る。"""
        center = Coordinate(latitude=36.122, longitude=139.700)
        in_band = self._point_at_distance(center, 2500.0)

        empty = MagicMock()
        empty.raise_for_status = MagicMock()
        empty.json.return_value = {"results": []}

        fanout_hit = self._poi_response("shrine-1", "久喜神社", in_band)

        def side_effect(*_args: object, **kwargs: object) -> MagicMock:
            params = kwargs.get("params", {})
            assert isinstance(params, dict)
            if "searchLocation" in params:
                assert "searchRegion" not in params
                return fanout_hit
            assert "searchRegion" in params
            assert "searchLocation" not in params
            return empty

        gateway._session.get.side_effect = side_effect

        hits = gateway.search_landmarks_nearby(
            center, 2500, target_count=1, distance_tolerance_percent=15.0, max_calls=20
        )
        assert len(hits) == 1
        assert hits[0].source == "fanout"
        assert hits[0].place_id == "apple:shrine-1"

    def test_max_callsを超えてクエリを投げないこと(self, gateway: AppleMapsGatewayImpl) -> None:
        """HTTP 予算を守り、全クエリバッグを回し切らない。"""
        center = Coordinate(latitude=35.0, longitude=139.0)
        empty = MagicMock()
        empty.raise_for_status = MagicMock()
        empty.json.return_value = {"results": []}
        gateway._session.get.return_value = empty

        hits = gateway.search_landmarks_nearby(
            center, 2000, target_count=5, distance_tolerance_percent=15.0, max_calls=3
        )
        assert hits == []
        assert gateway._session.get.call_count == 3

    def test_同一place_idはdedupされること(self, gateway: AppleMapsGatewayImpl) -> None:
        """同じ id は 1 件にまとめる。"""
        center = Coordinate(latitude=35.232, longitude=139.107)
        in_band = self._point_at_distance(center, 2000.0)
        gateway._session.get.return_value = self._poi_response("dup-1", "同じ場所", in_band)

        hits = gateway.search_landmarks_nearby(
            center, 2000, target_count=5, distance_tolerance_percent=15.0, max_calls=2
        )
        assert len(hits) == 1
        assert hits[0].place_id == "apple:dup-1"

    def test_距離帯外は除外すること(self, gateway: AppleMapsGatewayImpl) -> None:
        """近すぎる POI は距離帯フィルタで落とす。"""
        center = Coordinate(latitude=35.232, longitude=139.107)
        near = self._point_at_distance(center, 500.0)
        gateway._session.get.return_value = self._poi_response("near-1", "近すぎ", near)

        hits = gateway.search_landmarks_nearby(
            center, 2000, target_count=5, distance_tolerance_percent=15.0, max_calls=1
        )
        assert hits == []

    def test_HTTPエラーがstatus_code付きAppleMapsHTTPErrorになること(
        self, gateway: AppleMapsGatewayImpl
    ) -> None:
        """検索 API の HTTP エラーは数値 status_code を保持する。"""
        center = Coordinate(latitude=35.0, longitude=139.0)
        bad = MagicMock()
        bad.status_code = 500
        bad.text = "boom"
        bad.raise_for_status.side_effect = HTTPError(response=bad)
        gateway._session.get.return_value = bad

        with pytest.raises(AppleMapsHTTPError) as exc_info:
            gateway.search_landmarks_nearby(center, 2000, target_count=1, max_calls=1)
        assert exc_info.value.service_name == "Apple Maps Server API"
        assert exc_info.value.status_code == 500

    def test_HTTP400もstatus_codeで判定できること(self, gateway: AppleMapsGatewayImpl) -> None:
        """400 もメッセージ文字列ではなく status_code == 400 で分かる。"""
        center = Coordinate(latitude=35.0, longitude=139.0)
        bad = MagicMock()
        bad.status_code = 400
        bad.text = "other status mention: HTTP 400 is not how we classify"
        bad.raise_for_status.side_effect = HTTPError(response=bad)
        gateway._session.get.return_value = bad

        with pytest.raises(AppleMapsHTTPError) as exc_info:
            gateway.search_landmarks_nearby(center, 2000, target_count=1, max_calls=1)
        assert exc_info.value.status_code == 400
        assert exc_info.value.is_bad_request()
        assert isinstance(exc_info.value, ExternalServiceError)

    def test_本文にHTTP400とあっても500はbad_requestではないこと(
        self, gateway: AppleMapsGatewayImpl
    ) -> None:
        """本文の "HTTP 400" 文字列では 400 再試行判定をしない。"""
        center = Coordinate(latitude=35.0, longitude=139.0)
        bad = MagicMock()
        bad.status_code = 500
        bad.text = "upstream said HTTP 400 earlier; this response is 500"
        bad.raise_for_status.side_effect = HTTPError(response=bad)
        gateway._session.get.return_value = bad

        with pytest.raises(AppleMapsHTTPError) as exc_info:
            gateway.search_landmarks_nearby(center, 2000, target_count=1, max_calls=1)
        assert exc_info.value.status_code == 500
        assert not exc_info.value.is_bad_request()
        assert "HTTP 400" in exc_info.value.message

    def test_HTTPエラー本文は例外メッセージで切り詰められること(
        self, gateway: AppleMapsGatewayImpl
    ) -> None:
        """巨大なレスポンス本文を無制限に例外へ載せない。"""
        center = Coordinate(latitude=35.0, longitude=139.0)
        bad = MagicMock()
        bad.status_code = 502
        bad.text = "x" * 2000
        bad.raise_for_status.side_effect = HTTPError(response=bad)
        gateway._session.get.return_value = bad

        with pytest.raises(AppleMapsHTTPError) as exc_info:
            gateway.search_landmarks_nearby(center, 2000, target_count=1, max_calls=1)
        assert "truncated" in exc_info.value.message
        assert len(exc_info.value.message) < 500
