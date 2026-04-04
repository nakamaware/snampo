"""ルート生成結果DTO定義"""

from pydantic import BaseModel, ConfigDict, Field

from app.domain.value_objects import Coordinate, Landmark, StreetViewImage


class RoutePointDto(BaseModel):
    """ルート上の 1 地点を表すDTO"""

    model_config = ConfigDict(frozen=True)

    coordinate: Coordinate = Field(description="地点の座標")
    street_view_image: StreetViewImage | None = Field(
        default=None, description="地点に対応する Street View 画像"
    )
    landmark: Landmark | None = Field(default=None, description="地点に対応するランドマーク情報")


class RouteResultDto(BaseModel):
    """ルート生成結果DTO

    Application層から返されるルート情報を表します。

    Attributes:
        departure: 出発地点の座標
        destination: 目的地の詳細情報
        midpoints: 中間地点の詳細情報リスト
        overview_polyline: ルートの概要ポリライン文字列
    """

    model_config = ConfigDict(frozen=True)

    departure: Coordinate = Field(description="出発地点の座標")
    destination: RoutePointDto = Field(description="目的地の詳細情報")
    midpoints: list[RoutePointDto] = Field(description="中間地点の詳細情報リスト")
    overview_polyline: str = Field(description="ルートの概要ポリライン文字列")
