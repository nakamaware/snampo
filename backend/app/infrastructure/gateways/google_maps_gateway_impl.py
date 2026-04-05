"""Google Maps Gateway実装

Google Maps API (Street View, Directions) へのリクエストを処理します。
"""

import logging
from typing import Literal

import requests
from requests.exceptions import HTTPError, RequestException, Timeout
from tenacity import (
    retry,
    retry_if_exception_type,
    stop_after_attempt,
    wait_exponential,
)

from app.application.gateway_interfaces.google_maps_gateway import (
    GoogleMapsGateway,
    StreetViewMetadata,
)
from app.config import (
    GOOGLE_API_KEY,
    LANDMARK_INCLUDED_TYPES,
    PLACES_API_MAX_SEARCH_RADIUS_M,
    REQUEST_TIMEOUT_SECONDS,
)
from app.domain.exceptions import (
    ExternalServiceError,
    ExternalServiceTimeoutError,
    ExternalServiceValidationError,
)
from app.domain.value_objects import Coordinate, ImageSize, Landmark
from app.infrastructure import mappers

logger = logging.getLogger(__name__)

COORDINATE_DECIMAL_PLACES = 6


class RetryableHTTPError(HTTPError):
    """429/503エラー用のリトライ可能な例外"""


class GoogleMapsGatewayImpl(GoogleMapsGateway):
    """Google Maps API Gatewayの実装"""

    def _normalize_coordinate(self, coordinate: Coordinate) -> Coordinate:
        """API送信値で使う座標を丸める"""
        return Coordinate(
            latitude=round(coordinate.latitude, COORDINATE_DECIMAL_PLACES),
            longitude=round(coordinate.longitude, COORDINATE_DECIMAL_PLACES),
        )

    def _format_coordinate(self, coordinate: Coordinate) -> str:
        """APIリクエスト用の座標文字列を安定化する"""
        normalized_coordinate = self._normalize_coordinate(coordinate)
        return (
            f"{normalized_coordinate.latitude:.{COORDINATE_DECIMAL_PLACES}f},"
            f"{normalized_coordinate.longitude:.{COORDINATE_DECIMAL_PLACES}f}"
        )

    def _normalize_heading(self, heading: float | None) -> int | None:
        """Street View APIに送るheadingへ正規化する"""
        if heading is None:
            return None

        return int(heading)

    def get_directions(
        self,
        origin: Coordinate,
        destination: Coordinate,
        waypoints: list[Coordinate] | None = None,
    ) -> tuple[list[Coordinate], str]:
        """ルート情報を取得

        Args:
            origin: 出発地の座標
            destination: 目的地の座標
            waypoints: 経由地の座標リスト (通過点として扱われる)

        Returns:
            tuple[list[Coordinate], str]:
                (ルート座標リスト, overview_polyline文字列)
        """
        origin_str = self._format_coordinate(origin)
        destination_str = self._format_coordinate(destination)
        waypoints_str = ""
        if waypoints:
            # via: プレフィックスを使用して通過点 (pass through) として指定
            waypoints_str = "|".join(f"via:{self._format_coordinate(wp)}" for wp in waypoints)
        data = self._fetch_directions(origin_str, destination_str, waypoints_str)

        if data.get("status") != "OK":
            logger.error(f"Directions API returned non-OK status: {data.get('status')}")
            raise ExternalServiceValidationError(
                f"Directions API error: {data.get('status')}",
                service_name="Directions API",
            )

        routes = data.get("routes", [])
        if not routes or not routes[0].get("legs"):
            logger.error("Directions API returned empty routes")
            raise ExternalServiceValidationError(
                "No route found",
                service_name="Directions API",
            )

        route_coordinates: list[Coordinate] = []
        for step in routes[0]["legs"][0]["steps"]:
            route_coordinates.extend(mappers.decode_polyline(step["polyline"]["points"]))

        overview_polyline = routes[0]["overview_polyline"]["points"]

        return route_coordinates, overview_polyline

    def _fetch_directions(self, origin: str, destination: str, waypoints: str = "") -> dict:
        """Google Directions APIからルート情報を取得

        API Doc: https://developers.google.com/maps/documentation/directions/get-directions?hl=ja

        Args:
            origin: 出発地の座標 ("緯度,経度"形式の文字列)
            destination: 目的地の座標 ("緯度,経度"形式の文字列)
            waypoints: 経由地 ("via:緯度,経度|via:緯度,経度"形式、空文字列は経由地なし)

        Returns:
            dict: Directions APIのレスポンスJSON
        """
        url = "https://maps.googleapis.com/maps/api/directions/json"
        params = {
            "origin": origin,
            "destination": destination,
            "key": GOOGLE_API_KEY,
            "mode": "walking",
            "avoid": "highways|ferries",
        }
        if waypoints:
            params["waypoints"] = waypoints

        try:
            response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
            response.raise_for_status()
            return response.json()
        except Timeout as e:
            logger.error("Timeout error while fetching directions.")
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to retrieve directions",
                service_name="Directions API",
            ) from e
        except RequestException as e:
            logger.error(f"Request error while fetching directions: {e}")
            raise ExternalServiceError(
                f"Failed to retrieve directions: {e}",
                service_name="Directions API",
            ) from e

    def get_street_view_metadata(self, coordinate: Coordinate) -> StreetViewMetadata:
        """Street Viewメタデータを取得

        Args:
            coordinate: 座標

        Returns:
            StreetViewMetadata: メタデータ

        Raises:
            ExternalServiceValidationError: メタデータが不完全または無効な場合
        """
        normalized_coordinate = self._normalize_coordinate(coordinate)
        metadata_dict = self._fetch_street_view_metadata(normalized_coordinate)

        status = metadata_dict.get("status", "")
        location_coordinate: Coordinate | None = None

        if status == "OK":
            location = metadata_dict.get("location")
            if not isinstance(location, dict):
                logger.error(
                    f"Street View metadata missing or invalid 'location' field. "
                    f"Status: {status}, Metadata: {metadata_dict}"
                )
                raise ExternalServiceValidationError(
                    f"Street View metadata incomplete: 'location' field is missing or invalid. "
                    f"Status: {status}, Metadata: {metadata_dict}",
                    service_name="Street View Metadata API",
                )

            lat_value = location.get("lat")
            lng_value = location.get("lng")

            if lat_value is None or lng_value is None:
                logger.error(
                    f"Street View metadata missing 'lat' or 'lng' in location. "
                    f"Status: {status}, Location: {location}, Metadata: {metadata_dict}"
                )
                raise ExternalServiceValidationError(
                    f"Street View metadata incomplete: 'lat' or 'lng' is missing in location. "
                    f"Status: {status}, Location: {location}, Metadata: {metadata_dict}",
                    service_name="Street View Metadata API",
                )

            if not isinstance(lat_value, (int, float)) or not isinstance(lng_value, (int, float)):
                logger.error(
                    f"Street View metadata has invalid type for 'lat' or 'lng'. "
                    f"Status: {status}, Location: {location}, Metadata: {metadata_dict}"
                )
                raise ExternalServiceValidationError(
                    f"Street View metadata incomplete: 'lat' or 'lng' has invalid type. "
                    f"Status: {status}, Location: {location}, Metadata: {metadata_dict}",
                    service_name="Street View Metadata API",
                )

            location_coordinate = Coordinate(latitude=float(lat_value), longitude=float(lng_value))

        return StreetViewMetadata(status=status, location=location_coordinate)

    def _fetch_street_view_metadata(self, coordinate: Coordinate) -> dict:
        """Street View Metadata APIからメタデータを取得

        API Doc: https://developers.google.com/maps/documentation/streetview/metadata?hl=ja

        Args:
            coordinate: 座標

        Returns:
            dict: メタデータ
        """
        lat_float, lng_float = coordinate.to_float_tuple()
        url = "https://maps.googleapis.com/maps/api/streetview/metadata"
        params = {
            "location": f"{lat_float},{lng_float}",
            "source": "outdoor",
            "key": GOOGLE_API_KEY,
        }

        try:
            metadata_response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
            metadata_response.raise_for_status()
            return metadata_response.json()
        except Timeout as e:
            logger.error(
                "Timeout error while fetching Street View metadata for a requested location."
            )
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to retrieve Street View metadata",
                service_name="Street View Metadata API",
            ) from e
        except RequestException as e:
            logger.error(f"Request error while fetching Street View metadata: {e}")
            raise ExternalServiceError(
                f"Failed to retrieve Street View metadata: {e}",
                service_name="Street View Metadata API",
            ) from e

    def get_street_view_image(
        self, coordinate: Coordinate, image_size: ImageSize, heading: float | None = None
    ) -> bytes:
        """Street View画像を取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ
            heading: カメラの方向 (0-360度、北が0度、時計回り)。Noneの場合はデフォルト方向

        Returns:
            bytes: 画像データ
        """
        normalized_coordinate = self._normalize_coordinate(coordinate)
        normalized_heading = self._normalize_heading(heading)
        return self._fetch_street_view_image(normalized_coordinate, image_size, normalized_heading)

    def _fetch_street_view_image(
        self, coordinate: Coordinate, image_size: ImageSize, heading: float | None = None
    ) -> bytes:
        """Street View Static APIから画像を取得

        API Doc: https://developers.google.com/maps/documentation/streetview/request-streetview?hl=ja

        Args:
            coordinate: 座標
            image_size: 画像サイズ
            heading: カメラの方向 (0-360度、北が0度、時計回り)。Noneの場合はデフォルト方向

        Returns:
            bytes: 画像データ
        """
        lat_float, lng_float = coordinate.to_float_tuple()
        url = "https://maps.googleapis.com/maps/api/streetview"
        params = {
            "size": image_size.to_string(),
            "location": f"{lat_float},{lng_float}",
            "source": "outdoor",
            "key": GOOGLE_API_KEY,
        }

        # headingが指定されている場合、APIリクエストに追加
        if heading is not None:
            # Google Street View APIの仕様に従い、headingは0-360度の整数値
            params["heading"] = str(heading)

        try:
            response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
            response.raise_for_status()
            return response.content
        except Timeout as e:
            logger.error("Timeout error while fetching Street View image for a requested location.")
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to retrieve Street View image",
                service_name="Street View Static API",
            ) from e
        except RequestException as e:
            logger.error(f"Request error while fetching Street View image: {e}")
            raise ExternalServiceError(
                f"Failed to retrieve Street View image: {e}",
                service_name="Street View Static API",
            ) from e

    def search_landmarks_nearby(
        self,
        coordinate: Coordinate,
        radius: int,
        included_types: list[str] | None = None,
        rank_preference: Literal["POPULARITY", "DISTANCE"] = "POPULARITY",
    ) -> list[Landmark]:
        """Places API (New) でランドマーク検索

        Args:
            coordinate: 検索中心座標
            radius: 検索半径 (メートル)
            included_types: 検索対象のタイプリスト (Noneの場合はデフォルトタイプを使用)
            rank_preference: ソート順 ("POPULARITY" または "DISTANCE")

        Returns:
            list[Landmark]: ランドマークのリスト

        Raises:
            ExternalServiceError: API呼び出しエラーが発生した場合
        """
        if included_types is None:
            included_types = LANDMARK_INCLUDED_TYPES

        normalized_coordinate = self._normalize_coordinate(coordinate)
        places = self._search_nearby_once(
            normalized_coordinate, radius, included_types, rank_preference
        )

        landmarks: list[Landmark] = []
        for place in places:
            place_id = place.get("id")
            if not place_id:
                continue

            display_name_dict = place.get("displayName", {})
            display_name = (
                display_name_dict.get("text", "")
                if isinstance(display_name_dict, dict)
                else str(display_name_dict)
            )

            location = place.get("location", {})
            if not isinstance(location, dict):
                continue

            lat_value = location.get("latitude")
            lng_value = location.get("longitude")
            if lat_value is None or lng_value is None:
                continue

            try:
                landmark_coordinate = Coordinate(
                    latitude=float(lat_value), longitude=float(lng_value)
                )
            except (ValueError, TypeError):
                continue

            primary_type = place.get("primaryType")
            types = place.get("types")

            landmark = Landmark(
                place_id=place_id,
                display_name=display_name,
                coordinate=landmark_coordinate,
                primary_type=primary_type,
                types=types if isinstance(types, list) else None,
            )
            landmarks.append(landmark)

        return landmarks

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=1, min=1, max=10),
        retry=retry_if_exception_type((RetryableHTTPError, requests.exceptions.ConnectionError)),
    )
    def _search_nearby_once(
        self,
        coordinate: Coordinate,
        radius: int,
        included_types: list[str],
        rank_preference: str = "POPULARITY",
    ) -> list[dict]:
        """Places API v1 searchNearbyを1回呼び出す (リトライ付き)

        Args:
            coordinate: 検索中心座標
            radius: 検索半径 (メートル)
            included_types: 検索対象のタイプリスト
            rank_preference: ソート順 ("POPULARITY" または "DISTANCE")

        Returns:
            list[dict]: Places APIのレスポンス (placesリスト)

        Raises:
            ExternalServiceError: API呼び出しエラーが発生した場合
        """
        url = "https://places.googleapis.com/v1/places:searchNearby"

        lat_float, lng_float = coordinate.to_float_tuple()
        clamped_radius = max(50, min(radius, PLACES_API_MAX_SEARCH_RADIUS_M))

        request_body = {
            "includedPrimaryTypes": included_types,
            "maxResultCount": 20,
            "locationRestriction": {
                "circle": {
                    "center": {
                        "latitude": lat_float,
                        "longitude": lng_float,
                    },
                    "radius": clamped_radius,
                }
            },
            "languageCode": "ja",
            "rankPreference": rank_preference,
        }

        headers = {
            "Content-Type": "application/json",
            "X-Goog-Api-Key": GOOGLE_API_KEY,
            "X-Goog-FieldMask": (
                "places.id,places.displayName,places.location,places.primaryType,places.types"
            ),
        }

        try:
            response = requests.post(
                url, json=request_body, headers=headers, timeout=REQUEST_TIMEOUT_SECONDS
            )

            # 429/503エラーはリトライ可能な例外として発生
            if response.status_code in [429, 503]:
                raise RetryableHTTPError(
                    f"HTTP {response.status_code}: {response.reason}", response=response
                )

            # エラーレスポンスの詳細をログ出力
            if response.status_code >= 400:
                logger.error(f"Places API error response: {response.text}")

            # その他のエラーは通常通り例外を発生 (リトライしない)
            response.raise_for_status()

            data = response.json()
            return data.get("places", [])

        except Timeout as e:
            logger.error("Timeout error while fetching landmarks.")
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to retrieve landmarks",
                service_name="Places API",
            ) from e
        except RetryableHTTPError:
            # リトライ可能なエラーはそのまま再発生 (tenacityが処理)
            raise
        except RequestException as e:
            logger.error(f"Request error while fetching landmarks: {e}")
            raise ExternalServiceError(
                f"Failed to retrieve landmarks: {e}",
                service_name="Places API",
            ) from e

    def snap_to_road(self, coordinate: Coordinate) -> Coordinate | None:
        """Roads API (Nearest Roads) を使用して、指定された座標を最寄りの道路中心線にスナップする

        Args:
            coordinate: スナップする座標

        Returns:
            Coordinate | None: スナップされた座標。道路が見つからない場合は None

        Raises:
            ExternalServiceError: API呼び出しエラーが発生した場合
            ExternalServiceTimeoutError: API呼び出しがタイムアウトした場合
        """
        normalized_coordinate = self._normalize_coordinate(coordinate)
        return self._snap_to_road(normalized_coordinate)

    def _snap_to_road(self, coordinate: Coordinate) -> Coordinate | None:
        """Roads API (Nearest Roads) から座標を道路上にスナップ

        API Doc: https://developers.google.com/maps/documentation/roads/nearest?hl=ja

        Args:
            coordinate: スナップする座標

        Returns:
            Coordinate | None: スナップされた座標。道路が見つからない場合は None

        Raises:
            ExternalServiceError: API呼び出しエラーが発生した場合
            ExternalServiceTimeoutError: API呼び出しがタイムアウトした場合
        """
        lat_float, lng_float = coordinate.to_float_tuple()
        url = "https://roads.googleapis.com/v1/nearestRoads"
        params = {
            "points": f"{lat_float},{lng_float}",
            "key": GOOGLE_API_KEY,
        }

        try:
            response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
            response.raise_for_status()
            data = response.json()

            snapped_points = data.get("snappedPoints", [])
            if not snapped_points:
                logger.info(f"No road found near coordinate: {coordinate}")
                return None

            # 0番目の座標を使用する
            location = snapped_points[0].get("location", {})
            if not isinstance(location, dict):
                logger.warning(f"Invalid location data in Roads API response: {location}")
                return None

            lat_value = location.get("latitude")
            lng_value = location.get("longitude")
            if lat_value is None or lng_value is None:
                logger.warning(f"Missing latitude or longitude in Roads API response: {location}")
                return None

            snapped_coordinate = Coordinate(latitude=float(lat_value), longitude=float(lng_value))
            logger.info(f"Snapped coordinate {coordinate} to {snapped_coordinate}")
            return snapped_coordinate

        except Timeout as e:
            logger.error("Timeout error while snapping coordinate to road.")
            raise ExternalServiceTimeoutError(
                "Request timeout: Failed to snap coordinate to road",
                service_name="Roads API",
            ) from e
        except RequestException as e:
            logger.error(f"Request error while snapping coordinate to road: {e}")
            raise ExternalServiceError(
                f"Failed to snap coordinate to road: {e}",
                service_name="Roads API",
            ) from e
