"""Google Maps Gateway実装

Google Maps APIへのアクセスを実装します。
"""

import functools

from app.application.ports.google_maps_gateway import GoogleMapsGateway
from app.domain.value_objects import Coordinate, ImageSize, Latitude, Longitude
from app.infrastructure.external import google_maps_client


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
        """
        return self._get_street_view_metadata_cached(latitude, longitude)

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
