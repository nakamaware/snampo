"""Google Maps Gatewayポート定義

Google Maps APIへのアクセスを抽象化するポートです。
"""

from typing import Protocol

from app.domain.value_objects import Coordinate, ImageSize, Latitude, Longitude


class GoogleMapsGateway(Protocol):
    """Google Maps APIへのアクセスを提供するポート"""

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
        ...

    def get_street_view_metadata(self, latitude: Latitude, longitude: Longitude) -> dict:
        """Street Viewメタデータを取得

        Args:
            latitude: 緯度
            longitude: 経度

        Returns:
            dict: メタデータ
        """
        ...

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
        ...

    def coordinate_to_lat_lng_string(self, coordinate: Coordinate) -> str:
        """座標をGoogle Maps API用の文字列形式に変換

        Args:
            coordinate: 座標値オブジェクト

        Returns:
            str: "緯度,経度"形式の文字列
        """
        ...
