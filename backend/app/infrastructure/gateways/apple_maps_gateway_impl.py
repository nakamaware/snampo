"""Apple Maps 目的地検索。searchRegion と searchLocation は同時指定しない。"""

from __future__ import annotations

import hashlib
import logging
import math
import random
from typing import Any

import requests
from requests.exceptions import HTTPError, RequestException, Timeout

from app.application.gateway_interfaces.apple_maps_gateway import (
    AppleMapsGateway,
    AppleSearchHit,
    AppleSearchSource,
    prefix_apple_place_id,
)
from app.config import (
    LANDMARK_DISTANCE_TOLERANCE_PERCENT,
    LANDMARK_SEARCH_MAX_CALLS,
    LANDMARK_SEARCH_TARGET_COUNT,
    MIN_SEARCH_RADIUS_M,
    REQUEST_TIMEOUT_SECONDS,
)
from app.domain.exceptions import ExternalServiceError, ExternalServiceTimeoutError
from app.domain.services.coordinate_service import calculate_distance
from app.domain.services.landmark_service import (
    calculate_search_radius,
    generate_equidistant_circle_points,
)
from app.domain.value_objects import Coordinate
from app.infrastructure.gateways.apple_maps_auth import (
    APPLE_MAPS_BASE_URL,
    AppleMapsTokenProvider,
)

logger = logging.getLogger(__name__)

SERVICE_NAME = "Apple Maps Server API"
# 例外メッセージ / ログに載せる Apple レスポンス本文の上限
_MAX_ERROR_BODY_CHARS = 300

# 1 度の緯度あたりのおよそのメートル (bbox 近似用)
_METERS_PER_DEGREE_LAT = 111_320.0

# 高収穫バケット (先頭 3 クエリ用: 各バケットから 1 つ)
OUTDOOR_QUERY_BUCKET: tuple[str, ...] = ("公園", "展望台")
CULTURE_QUERY_BUCKET: tuple[str, ...] = ("神社", "寺", "城")
CASUAL_QUERY_BUCKET: tuple[str, ...] = ("カフェ", "パン", "温泉")

# 残りクエリ (バケットの余りと合わせてシャッフル)
REMAINING_QUERY_BAG: tuple[str, ...] = (
    "博物館",
    "美術館",
    "銭湯",
    "道の駅",
    "灯台",
    "滝",
    "湖",
    "キャンプ",
    "遊園地",
)

SearchRegion = tuple[float, float, float, float]  # north, east, south, west


class AppleMapsHTTPError(ExternalServiceError):
    """Apple Maps API の HTTP エラー (status_code を数値で保持する)

    ステータス判定はメッセージ文字列ではなく status_code を使うこと。
    """

    def __init__(
        self,
        message: str,
        *,
        service_name: str | None = None,
        status_code: int | None = None,
    ) -> None:
        """初期化

        Args:
            message: エラーメッセージ
            service_name: サービス名
            status_code: HTTP ステータスコード
        """
        self.status_code = status_code
        super().__init__(message, service_name=service_name)

    def is_bad_request(self) -> bool:
        """HTTP 400 かどうか。メッセージ文字列ではなく status_code で判定する。"""
        return self.status_code == 400


def _truncate_error_body(text: str | None, *, limit: int = _MAX_ERROR_BODY_CHARS) -> str:
    """例外メッセージ用にレスポンス本文を切り詰める。"""
    if not text:
        return ""
    if len(text) <= limit:
        return text
    return f"{text[:limit]}...(truncated)"


def circle_to_search_region(center: Coordinate, radius_m: float) -> SearchRegion:
    """中心 + 半径 (m) を Apple searchRegion (north,east,south,west) に近似する。"""
    lat = float(center.latitude)
    lng = float(center.longitude)
    delta_lat = radius_m / _METERS_PER_DEGREE_LAT
    cos_lat = math.cos(math.radians(lat))
    meters_per_degree_lng = _METERS_PER_DEGREE_LAT * max(abs(cos_lat), 1e-6)
    delta_lng = radius_m / meters_per_degree_lng

    north = min(90.0, lat + delta_lat)
    south = max(-90.0, lat - delta_lat)
    east = lng + delta_lng
    west = lng - delta_lng
    if east > 180.0:
        east = 180.0
    if west < -180.0:
        west = -180.0
    return (north, east, south, west)


def format_search_region(region: SearchRegion) -> str:
    """searchRegion クエリ文字列 (north,east,south,west) を作る。"""
    north, east, south, west = region
    return f"{north},{east},{south},{west}"


def distance_band_bounds(
    target_distance_m: float,
    tolerance_percent: float,
) -> tuple[float, float]:
    """目標距離に対する ±tolerance% の下限・上限 (m) を返す。"""
    ratio = tolerance_percent / 100.0
    return target_distance_m * (1.0 - ratio), target_distance_m * (1.0 + ratio)


def stable_search_seed(center: Coordinate, radius_m: int) -> int:
    """同一中心・半径で再現可能なシャッフル用シードを作る。"""
    key = f"{float(center.latitude):.6f}:{float(center.longitude):.6f}:{radius_m}"
    digest = hashlib.sha256(key.encode("utf-8")).hexdigest()
    return int(digest[:16], 16)


def build_stratified_query_bag(seed: int) -> list[str]:
    """層別シャッフルしたクエリバッグを返す。

    先頭 3 件: outdoor / culture / casual 各バケットをシャッフルした先頭 1 件。
    以降: バケット余り + REMAINING をシャッフル。
    """
    rng = random.Random(seed)  # noqa: S311 — クエリ順の再現用。暗号用途ではない
    outdoor = list(OUTDOOR_QUERY_BUCKET)
    culture = list(CULTURE_QUERY_BUCKET)
    casual = list(CASUAL_QUERY_BUCKET)
    rng.shuffle(outdoor)
    rng.shuffle(culture)
    rng.shuffle(casual)

    first_three = [outdoor[0], culture[0], casual[0]]
    leftovers = outdoor[1:] + culture[1:] + casual[1:] + list(REMAINING_QUERY_BAG)
    rng.shuffle(leftovers)
    return first_three + leftovers


def _poi_search_params(query: str, **geo: str) -> dict[str, str]:
    return {
        "q": query,
        "resultTypeFilter": "Poi",
        "lang": "ja-JP",
        "limitToCountries": "JP",
        **geo,
    }


class AppleMapsGatewayImpl(AppleMapsGateway):
    """Apple Maps Server API 検索の実装 (目的地ランドマーク検索向け)"""

    def __init__(
        self,
        token_provider: AppleMapsTokenProvider | None = None,
        *,
        base_url: str = APPLE_MAPS_BASE_URL,
        session: requests.Session | None = None,
    ) -> None:
        """初期化

        Args:
            token_provider: access token 供給 (None なら初回アクセス時に from_config)
            base_url: API ベース URL
            session: requests.Session
        """
        self._token_provider = token_provider
        self._base_url = base_url.rstrip("/")
        self._session = session or requests.Session()

    def _provider(self) -> AppleMapsTokenProvider:
        if self._token_provider is None:
            self._token_provider = AppleMapsTokenProvider.from_config()
        return self._token_provider

    def search_landmarks_nearby(
        self,
        coordinate: Coordinate,
        radius_m: int,
        *,
        target_count: int | None = None,
        distance_tolerance_percent: float | None = None,
        max_calls: int | None = None,
    ) -> list[AppleSearchHit]:
        """層別クエリ検索 → 不足時円周ファンアウトで距離帯内 POI を返す。"""
        if radius_m <= 0:
            raise ValueError("radius_m must be positive")

        resolved_target = LANDMARK_SEARCH_TARGET_COUNT if target_count is None else target_count
        resolved_tolerance = (
            LANDMARK_DISTANCE_TOLERANCE_PERCENT
            if distance_tolerance_percent is None
            else distance_tolerance_percent
        )
        resolved_max_calls = LANDMARK_SEARCH_MAX_CALLS if max_calls is None else max_calls
        if resolved_max_calls <= 0:
            return []

        min_distance_m, max_distance_m = distance_band_bounds(float(radius_m), resolved_tolerance)
        region = circle_to_search_region(coordinate, max_distance_m)
        queries = build_stratified_query_bag(stable_search_seed(coordinate, radius_m))

        hits_by_id: dict[str, AppleSearchHit] = {}
        calls = 0

        for query in queries:
            if len(hits_by_id) >= resolved_target or calls >= resolved_max_calls:
                break
            raw_results = self._search_by_query_region(region=region, query=query)
            calls += 1
            self._merge_in_band_hits(
                hits_by_id=hits_by_id,
                raw_results=raw_results,
                center=coordinate,
                min_distance_m=min_distance_m,
                max_distance_m=max_distance_m,
                source="query",
            )

        if len(hits_by_id) < resolved_target and calls < resolved_max_calls:
            tolerance_ratio = resolved_tolerance / 100.0
            search_radius = calculate_search_radius(radius_m, tolerance_ratio, MIN_SEARCH_RADIUS_M)
            circle_points = generate_equidistant_circle_points(
                coordinate,
                radius_m,
                float(search_radius),
                seed=stable_search_seed(coordinate, radius_m) ^ 0xA5A5_5A5A,
            )
            for query_index, (point_lat, point_lng) in enumerate(circle_points):
                if len(hits_by_id) >= resolved_target or calls >= resolved_max_calls:
                    break
                point = Coordinate(latitude=point_lat, longitude=point_lng)
                query = queries[query_index % len(queries)]
                raw_results = self._search_by_query_location(location=point, query=query)
                calls += 1
                self._merge_in_band_hits(
                    hits_by_id=hits_by_id,
                    raw_results=raw_results,
                    center=coordinate,
                    min_distance_m=min_distance_m,
                    max_distance_m=max_distance_m,
                    source="fanout",
                )

        logger.debug(
            "Apple landmark search done: hits=%s calls=%s/%s center=(%.4f,%.4f) radius=%s",
            len(hits_by_id),
            calls,
            resolved_max_calls,
            float(coordinate.latitude),
            float(coordinate.longitude),
            radius_m,
        )
        return list(hits_by_id.values())

    def _search_by_query_region(
        self,
        *,
        region: SearchRegion,
        query: str,
    ) -> list[dict[str, Any]]:
        """searchRegion + 日本語 q (searchLocation は付けない)。"""
        return self._get_search_results(
            _poi_search_params(query, searchRegion=format_search_region(region))
        )

    def _search_by_query_location(
        self,
        *,
        location: Coordinate,
        query: str,
    ) -> list[dict[str, Any]]:
        """searchLocation + 日本語 q (searchRegion は付けない)。"""
        lat, lng = location.to_float_tuple()
        return self._get_search_results(
            _poi_search_params(query, searchLocation=f"{lat},{lng}")
        )

    def _get_search_results(self, params: dict[str, str]) -> list[dict[str, Any]]:
        access_token = self._provider().get_access_token()
        url = f"{self._base_url}/search"
        try:
            response = self._session.get(
                url,
                headers={"Authorization": f"Bearer {access_token}"},
                params=params,
                timeout=REQUEST_TIMEOUT_SECONDS,
            )
            response.raise_for_status()
            data = response.json()
        except Timeout as error:
            logger.error("Timeout while calling Apple Maps /v1/search")
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to search Apple Maps",
                service_name=SERVICE_NAME,
            ) from error
        except HTTPError as error:
            status = error.response.status_code if error.response is not None else None
            raw_body = error.response.text if error.response is not None else ""
            body = _truncate_error_body(raw_body)
            message = f"Failed to search Apple Maps: HTTP {status} {body}".strip()
            raise AppleMapsHTTPError(
                message,
                service_name=SERVICE_NAME,
                status_code=status,
            ) from error
        except RequestException as error:
            logger.error("Request error while calling Apple Maps /v1/search: %s", error)
            raise ExternalServiceError(
                f"Failed to search Apple Maps: {error}",
                service_name=SERVICE_NAME,
            ) from error

        results = data.get("results", [])
        if not isinstance(results, list):
            return []
        return [item for item in results if isinstance(item, dict)]

    def _merge_in_band_hits(
        self,
        *,
        hits_by_id: dict[str, AppleSearchHit],
        raw_results: list[dict[str, Any]],
        center: Coordinate,
        min_distance_m: float,
        max_distance_m: float,
        source: AppleSearchSource,
    ) -> None:
        for item in raw_results:
            hit = self._parse_hit(item, center=center, source=source)
            if hit is None:
                continue
            if hit.distance_m < min_distance_m or hit.distance_m > max_distance_m:
                continue
            if hit.place_id in hits_by_id:
                continue
            hits_by_id[hit.place_id] = hit

    def _parse_hit(
        self,
        item: dict[str, Any],
        *,
        center: Coordinate,
        source: AppleSearchSource,
    ) -> AppleSearchHit | None:
        raw_id = item.get("id") or item.get("identifier") or item.get("muid")
        if raw_id is None:
            return None
        place_id = prefix_apple_place_id(str(raw_id))

        name = item.get("name")
        if not name or not isinstance(name, str):
            return None

        coordinate_data = item.get("coordinate")
        if not isinstance(coordinate_data, dict):
            return None
        lat_value = coordinate_data.get("latitude")
        lng_value = coordinate_data.get("longitude")
        if lat_value is None or lng_value is None:
            return None
        try:
            landmark_coordinate = Coordinate(
                latitude=float(lat_value),
                longitude=float(lng_value),
            )
        except (TypeError, ValueError):
            return None

        distance_m = calculate_distance(center, landmark_coordinate)
        poi_category = item.get("poiCategory")
        if poi_category is not None and not isinstance(poi_category, str):
            poi_category = str(poi_category)

        return AppleSearchHit(
            place_id=place_id,
            display_name=name,
            coordinate=landmark_coordinate,
            distance_m=distance_m,
            source=source,
            poi_category=poi_category,
        )
