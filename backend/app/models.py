"""Pydanticモデル定義

APIレスポンス用のデータモデルを定義します。
"""

from pydantic import BaseModel

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


class RouteResponse(BaseModel):
    """ルート情報を表すモデル"""

    departure: Point
    destination: MidPoint
    midpoints: list[MidPoint]
    overview_polyline: str
