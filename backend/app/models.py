"""Pydanticモデル定義

APIレスポンス用のデータモデルを定義します。
"""

from pydantic import BaseModel, Field

from app.value_objects import Latitude, Longitude


class Point(BaseModel):
    """座標点を表すモデル"""

    latitude: Latitude
    longitude: Longitude


class MidPoint(BaseModel):
    """中間地点を表すモデル(画像情報を含む)"""

    latitude: Latitude
    longitude: Longitude
    image_latitude: Latitude | None = None
    image_longitude: Longitude | None = None
    image_utf8: str | None = None


class StreetViewImageResponse(BaseModel):
    """Street View画像のメタデータと画像データを表すモデル"""

    metadata_latitude: Latitude
    metadata_longitude: Longitude
    original_latitude: Latitude
    original_longitude: Longitude
    image_data: str


class RouteRequest(BaseModel):
    """ルート生成リクエストを表すモデル"""

    current_lat: float = Field(
        ...,
        description="現在地の緯度",
        ge=-90,
        le=90,
        example=35.6762,
    )
    current_lng: float = Field(
        ...,
        description="現在地の経度",
        ge=-180,
        le=180,
        example=139.6503,
    )
    radius: float = Field(
        ...,
        description="目的地を生成する半径 (メートル単位)",
        gt=0,
        le=40075000,  # 地球の赤道一周の長さ (メートル)
        example=5000,
    )


class RouteResponse(BaseModel):
    """ルート情報を表すモデル"""

    departure: Point
    destination: MidPoint
    midpoints: list[MidPoint]
    overview_polyline: str
