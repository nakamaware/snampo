"""Google Maps Gatewayアダプター

Google Maps APIへのアクセスを実装するアダプターです。
"""

import functools
import logging

from injector import inject

from app.adapters.client_interfaces.google_maps_client_if import GoogleMapsClientIf
from app.application.gateway_interfaces.google_maps_gateway_if import (
    GoogleMapsGatewayIf,
    StreetViewMetadata,
)
from app.domain.exceptions import ExternalServiceValidationError
from app.domain.value_objects import Coordinate, ImageSize

logger = logging.getLogger(__name__)


class GoogleMapsGatewayImpl(GoogleMapsGatewayIf):
    """Google Maps APIへのアクセスを提供する実装"""

    @inject
    def __init__(self, google_maps_client: GoogleMapsClientIf) -> None:
        """初期化処理でキャッシュ関数を作成

        Args:
            google_maps_client: Google Maps APIクライアント
        """
        self._client = google_maps_client
        self._get_directions_cached = functools.lru_cache(maxsize=128)(
            lambda origin_str, destination_str: self._client.fetch_directions(
                origin_str, destination_str
            )
        )
        self._get_street_view_metadata_cached = functools.lru_cache(maxsize=128)(
            lambda coordinate: self._client.fetch_street_view_metadata(coordinate)
        )
        self._get_street_view_image_cached = functools.lru_cache(maxsize=128)(
            lambda coordinate, image_size: self._client.fetch_street_view_image(
                coordinate, image_size
            )
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
        origin_str = self._coordinate_to_lat_lng_string(origin)
        destination_str = self._coordinate_to_lat_lng_string(destination)
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
            route_coordinates.extend(self._decode_polyline(step["polyline"]["points"]))

        overview_polyline = routes[0]["overview_polyline"]["points"]

        return route_coordinates, overview_polyline

    @staticmethod
    def _coordinate_to_lat_lng_string(coordinate: Coordinate) -> str:
        """座標をGoogle Maps API用の文字列形式に変換

        Args:
            coordinate: 座標値オブジェクト

        Returns:
            str: "緯度,経度"形式の文字列
        """
        return f"{coordinate.latitude.to_float()},{coordinate.longitude.to_float()}"

    @staticmethod
    def _decode_polyline(polyline_str: str) -> list[Coordinate]:
        """Google Maps APIのポリラインをデコードして座標リストを生成

        Args:
            polyline_str: ポリラインの文字列

        Returns:
            list[Coordinate]: 座標リスト
        """
        index = 0
        coordinates = []
        lat = 0
        lng = 0

        while index < len(polyline_str):
            shift = 0
            result = 0
            while True:
                byte = ord(polyline_str[index]) - 63
                index += 1
                result |= (byte & 0x1F) << shift
                shift += 5
                if byte < 0x20:
                    break

            dlat = ~(result >> 1) if result & 1 else (result >> 1)
            lat += dlat

            shift = 0
            result = 0
            while True:
                byte = ord(polyline_str[index]) - 63
                index += 1
                result |= (byte & 0x1F) << shift
                shift += 5
                if byte < 0x20:
                    break

            dlng = ~(result >> 1) if result & 1 else (result >> 1)
            lng += dlng

            lat_float = lat * 1e-5
            lng_float = lng * 1e-5
            coordinates.append(Coordinate(latitude=lat_float, longitude=lng_float))

        return coordinates

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

    def get_street_view_image(self, coordinate: Coordinate, image_size: ImageSize) -> bytes:
        """Street View画像を取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            bytes: 画像データ
        """
        return self._get_street_view_image_cached(coordinate, image_size)
