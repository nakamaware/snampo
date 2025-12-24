"""Google Maps Clientポート定義

Google Maps APIクライアントへのインターフェースを定義します。
"""

from abc import ABC, abstractmethod

from app.domain.value_objects import Coordinate, ImageSize


class GoogleMapsClientIf(ABC):
    """Google Maps APIクライアントのインターフェース"""

    @abstractmethod
    def fetch_directions(self, origin: str, destination: str) -> dict:
        """Google Directions APIからルート情報を取得

        Args:
            origin: 出発地の座標 ("緯度,経度"形式の文字列)
            destination: 目的地の座標 ("緯度,経度"形式の文字列)

        Returns:
            dict: Directions APIのレスポンスJSON
        """
        ...

    @abstractmethod
    def fetch_street_view_metadata(self, coordinate: Coordinate) -> dict:
        """Street View Metadata APIからメタデータを取得

        Args:
            coordinate: 座標

        Returns:
            dict: メタデータ
        """
        ...

    @abstractmethod
    def fetch_street_view_image(self, coordinate: Coordinate, image_size: ImageSize) -> bytes:
        """Street View Static APIから画像を取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            bytes: 画像データ
        """
        ...
