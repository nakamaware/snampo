"""Google Maps Gatewayポート定義

Google Maps APIへのアクセスを抽象化するポートです。
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass

from app.domain.exceptions import ExternalServiceValidationError
from app.domain.value_objects import Coordinate, ImageSize


@dataclass(frozen=True)
class StreetViewMetadata:
    """Street Viewメタデータを表すDTO

    Gatewayの返り値として使用されます。

    Attributes:
        status: メタデータのステータス(例: "OK", "ZERO_RESULTS")
        location: 画像の実際の座標(status == "OK"の場合のみ設定、それ以外はNone)
    """

    status: str
    location: Coordinate | None

    def __init__(self, status: str, location: Coordinate | None = None) -> None:
        """Street Viewメタデータを初期化

        Args:
            status: メタデータのステータス
            location: 画像の実際の座標(status == "OK"の場合のみ設定)

        Raises:
            ExternalServiceValidationError: メタデータが無効な場合
        """
        # frozen dataclassのフィールドを設定するためにobject.__setattr__を使用
        object.__setattr__(self, "status", status)

        # status == "OK"の場合、locationの検証を行う
        if status == "OK":
            if location is None:
                raise ExternalServiceValidationError(
                    "Street View metadata incomplete: 'location' is required when status is 'OK'",
                    service_name="Street View API",
                )
            object.__setattr__(self, "location", location)
        else:
            object.__setattr__(self, "location", None)


class GoogleMapsGatewayIf(ABC):
    """Google Maps APIへのアクセスを提供するポート"""

    @abstractmethod
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
