"""Google Maps Gateway実装

Google Maps APIへのアクセスを実装します。
"""

import functools
import logging

from app.application.ports.google_maps_gateway import GoogleMapsGateway
from app.domain.value_objects import Coordinate, ImageSize, Latitude, Longitude
from app.infrastructure.external import google_maps_client

logger = logging.getLogger(__name__)


class GoogleMapsGatewayImpl(GoogleMapsGateway):
    """Google Maps APIへのアクセスを提供するGateway実装"""

    def __init__(self) -> None:
        """初期化処理でキャッシュ関数を作成"""
        self._get_directions_cached = functools.lru_cache(maxsize=128)(
            lambda origin, destination: google_maps_client.fetch_directions(origin, destination)
        )
        self._get_street_view_metadata_cached = functools.lru_cache(maxsize=128)(
            lambda latitude, longitude: google_maps_client.fetch_street_view_metadata(
                latitude, longitude
            )
        )
        self._get_street_view_image_cached = functools.lru_cache(maxsize=128)(
            lambda latitude, longitude, image_size: google_maps_client.fetch_street_view_image(
                latitude, longitude, image_size
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
        return self._get_directions_cached(origin, destination)

    def get_street_view_metadata(self, latitude: Latitude, longitude: Longitude) -> dict:
        """Street Viewメタデータを取得

        Args:
            latitude: 緯度
            longitude: 経度

        Returns:
            dict: メタデータ

        Raises:
            ValueError: メタデータが不完全または無効な場合
        """
        metadata = self._get_street_view_metadata_cached(latitude, longitude)

        # status == "OK"の場合、location辞書とlat/lngキーの存在を検証
        if metadata.get("status") == "OK":
            location = metadata.get("location")
            if not isinstance(location, dict):
                logger.error(
                    f"Street View metadata missing or invalid 'location' field. "
                    f"Status: {metadata.get('status')}, Metadata: {metadata}"
                )
                raise ValueError(
                    f"Street View metadata incomplete: 'location' field is missing or invalid. "
                    f"Status: {metadata.get('status')}, Metadata: {metadata}"
                )

            lat_value = location.get("lat")
            lng_value = location.get("lng")

            if lat_value is None or lng_value is None:
                logger.error(
                    f"Street View metadata missing 'lat' or 'lng' in location. "
                    f"Status: {metadata.get('status')}, Location: {location}, Metadata: {metadata}"
                )
                raise ValueError(
                    f"Street View metadata incomplete: 'lat' or 'lng' is missing in location. "
                    f"Status: {metadata.get('status')}, Location: {location}, Metadata: {metadata}"
                )

            # 型の検証 (floatまたはint型であることを確認)
            if not isinstance(lat_value, (int, float)) or not isinstance(lng_value, (int, float)):
                logger.error(
                    f"Street View metadata has invalid type for 'lat' or 'lng'. "
                    f"Status: {metadata.get('status')}, Location: {location}, Metadata: {metadata}"
                )
                raise ValueError(
                    f"Street View metadata incomplete: 'lat' or 'lng' has invalid type. "
                    f"Status: {metadata.get('status')}, Location: {location}, Metadata: {metadata}"
                )

        return metadata

    def get_street_view_image(
        self, latitude: Latitude, longitude: Longitude, image_size: ImageSize
    ) -> bytes:
        """Street View画像を取得

        Args:
            latitude: 緯度
            longitude: 経度
            image_size: 画像サイズ

        Returns:
            bytes: 画像データ
        """
        return self._get_street_view_image_cached(latitude, longitude, image_size)

    def coordinate_to_lat_lng_string(self, coordinate: Coordinate) -> str:
        """座標をGoogle Maps API用の文字列形式に変換

        Args:
            coordinate: 座標値オブジェクト

        Returns:
            str: "緯度,経度"形式の文字列
        """
        return google_maps_client.coordinate_to_lat_lng_string(coordinate)
