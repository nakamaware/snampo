"""Pydanticモデル定義

APIレスポンス用のデータモデルを定義します。
"""

from pydantic import BaseModel


class Point(BaseModel):
    """座標点を表すモデル"""

    latitude: float
    longitude: float


class MidPoint(BaseModel):
    """中間地点を表すモデル(画像情報を含む)"""

    latitude: float
    longitude: float
    image_latitude: float | None = None
    image_longitude: float | None = None
    image_utf8: str | None = None


class StreetViewImageResponse(BaseModel):
    """Street View画像のメタデータと画像データを表すモデル"""

    metadata_latitude: float
    metadata_longitude: float
    original_latitude: float
    original_longitude: float
    image_data: str


class RouteResponse(BaseModel):
    """ルート情報を表すモデル"""

    departure: Point
    destination: MidPoint
    midpoints: list[MidPoint]
    overview_polyline: str
