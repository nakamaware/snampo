"""Google Maps Gateway実装

Google Maps API (Street View, Directions) へのリクエストを処理します。
"""

import functools
import logging

import requests
from requests.exceptions import RequestException, Timeout

from app.application.gateway_interfaces.google_maps_gateway import (
    GoogleMapsGateway,
    StreetViewMetadata,
)
from app.config import GOOGLE_API_KEY, REQUEST_TIMEOUT_SECONDS
from app.domain.exceptions import (
    ExternalServiceError,
    ExternalServiceTimeoutError,
    ExternalServiceValidationError,
)
from app.domain.value_objects import Coordinate, ImageSize
from app.infrastructure import mappers

logger = logging.getLogger(__name__)


class GoogleMapsGatewayImpl(GoogleMapsGateway):
    """Google Maps API Gatewayの実装"""

    def __init__(self) -> None:
        """初期化処理でキャッシュ関数を作成"""
        # TODO: 緯度経度の小数点以下の桁数を指定しないと、適切にキャッシュが効かなさそう
        self._get_directions_cached = functools.lru_cache(maxsize=128)(
            lambda origin_str, destination_str: self._fetch_directions(origin_str, destination_str)
        )
        self._get_street_view_metadata_cached = functools.lru_cache(maxsize=128)(
            lambda coordinate: self._fetch_street_view_metadata(coordinate)
        )
        self._get_street_view_image_cached = functools.lru_cache(maxsize=128)(
            lambda coordinate, image_size: self._fetch_street_view_image(coordinate, image_size)
        )

    def get_directions(
        self, origin: Coordinate, destination: Coordinate
    ) -> tuple[list[Coordinate], str]:
        """ルート情報を取得

        Args:
            origin: 出発地の座標
            destination: 目的地の座標

        Returns:
            tuple[list[Coordinate], str]:
                (ルート座標リスト, overview_polyline文字列)
        """
        origin_str = f"{origin.latitude},{origin.longitude}"
        destination_str = f"{destination.latitude},{destination.longitude}"
        data = self._get_directions_cached(origin_str, destination_str)

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

    def _fetch_directions(self, origin: str, destination: str) -> dict:
        """Google Directions APIからルート情報を取得

        API Doc: https://developers.google.com/maps/documentation/directions/get-directions?hl=ja

        Args:
            origin: 出発地の座標 ("緯度,経度"形式の文字列)
            destination: 目的地の座標 ("緯度,経度"形式の文字列)

        Returns:
            dict: Directions APIのレスポンスJSON
        """
        url = "https://maps.googleapis.com/maps/api/directions/json"
        params = {"origin": origin, "destination": destination, "key": GOOGLE_API_KEY}

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
        metadata_dict = self._get_street_view_metadata_cached(coordinate)

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

        Args:
            coordinate: 座標

        Returns:
            dict: メタデータ
        """
        lat_float, lng_float = coordinate.to_float_tuple()
        url = (
            f"https://maps.googleapis.com/maps/api/streetview/metadata"
            f"?location={lat_float},{lng_float}&key={GOOGLE_API_KEY}"
        )

        try:
            metadata_response = requests.get(url, timeout=REQUEST_TIMEOUT_SECONDS)
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

    def get_street_view_image(self, coordinate: Coordinate, image_size: ImageSize) -> bytes:
        """Street View画像を取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            bytes: 画像データ
        """
        return self._get_street_view_image_cached(coordinate, image_size)

    def _fetch_street_view_image(self, coordinate: Coordinate, image_size: ImageSize) -> bytes:
        """Street View Static APIから画像を取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            bytes: 画像データ
        """
        lat_float, lng_float = coordinate.to_float_tuple()
        url = "https://maps.googleapis.com/maps/api/streetview"
        params = {
            "size": image_size.to_string(),
            "location": f"{lat_float},{lng_float}",
            "key": GOOGLE_API_KEY,
        }

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
