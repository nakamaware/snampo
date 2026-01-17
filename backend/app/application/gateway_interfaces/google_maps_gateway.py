"""Google Maps Gatewayポート定義

Google Maps APIへのアクセスを抽象化するポートです。
"""

from abc import ABC, abstractmethod
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field

from app.domain.value_objects import Coordinate, ImageSize, Landmark


class StreetViewMetadata(BaseModel):
    """Street Viewメタデータを表すDTO

    Gatewayの返り値として使用されます。

    Attributes:
        status: メタデータのステータス(例: "OK", "ZERO_RESULTS")
        location: 画像の実際の座標(status == "OK"の場合のみ設定、それ以外はNone)
    """

    model_config = ConfigDict(frozen=True)

    status: str = Field(description='メタデータのステータス (例: "OK", "ZERO_RESULTS")')
    location: Coordinate | None = Field(
        default=None,
        description='画像の実際の座標 (status == "OK"の場合のみ設定、それ以外はNone)',
    )


class GoogleMapsGateway(ABC):
    """Google Maps APIへのアクセスを提供するポート"""

    @abstractmethod
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
        ...

    @abstractmethod
    def get_street_view_metadata(self, coordinate: Coordinate) -> StreetViewMetadata:
        """Street Viewメタデータを取得

        Args:
            coordinate: 座標

        Returns:
            StreetViewMetadata: メタデータ

        Raises:
            ExternalServiceValidationError: メタデータが不完全または無効な場合
        """
        ...

    @abstractmethod
    def get_street_view_image(self, coordinate: Coordinate, image_size: ImageSize) -> bytes:
        """Street View画像を取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            bytes: 画像データ
        """
        ...

    @abstractmethod
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
        ...

    @abstractmethod
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
        ...
