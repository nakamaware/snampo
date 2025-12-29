"""Google Maps Gatewayポート定義

Google Maps APIへのアクセスを抽象化するポートです。
"""

from abc import ABC, abstractmethod
from typing import cast

from pydantic import BaseModel, ConfigDict, Field, model_validator

from app.domain.exceptions import ExternalServiceValidationError
from app.domain.value_objects import Coordinate, ImageSize


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

    @model_validator(mode="before")
    @classmethod
    def validate_metadata(cls, data: dict | object) -> dict:
        """Street Viewメタデータを検証・正規化

        status == "OK"の場合、locationが必須であることを確認します。
        status != "OK"の場合、locationをNoneに設定します。

        Args:
            data: 初期化データ

        Returns:
            dict: 正規化された初期化データ

        Raises:
            ExternalServiceValidationError: メタデータが無効な場合
        """
        if not isinstance(data, dict):
            return cast(dict, data)

        status = data.get("status")
        location = data.get("location")

        if status == "OK":
            if location is None:
                raise ExternalServiceValidationError(
                    "Street View metadata incomplete: 'location' is required when status is 'OK'",
                    service_name="Street View API",
                )
        else:
            # status != "OK"の場合、locationをNoneに設定
            data["location"] = None

        return data


class GoogleMapsGateway(ABC):
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
