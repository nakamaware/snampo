"""Google Maps API呼び出しクライアント

Google Maps API (Street View, Directions) へのリクエストを処理します。
"""

import logging

import requests
from requests.exceptions import RequestException, Timeout

from app.adapters.client_interfaces.google_maps_client_if import GoogleMapsClientIf
from app.config import GOOGLE_API_KEY, REQUEST_TIMEOUT_SECONDS
from app.domain.exceptions import (
    ExternalServiceError,
    ExternalServiceTimeoutError,
)
from app.domain.value_objects import Coordinate, ImageSize

logger = logging.getLogger(__name__)


class GoogleMapsClientImpl(GoogleMapsClientIf):
    """Google Maps APIクライアントの実装"""

    def fetch_directions(self, origin: str, destination: str) -> dict:
        """Google Directions APIからルート情報を取得

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

    def fetch_street_view_metadata(self, coordinate: Coordinate) -> dict:
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

    def fetch_street_view_image(self, coordinate: Coordinate, image_size: ImageSize) -> bytes:
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
