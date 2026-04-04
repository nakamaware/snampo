"""ルートAPIスキーマ定義"""

import base64
from typing import Annotated, Literal
from urllib.parse import urlencode

from pydantic import BaseModel, Discriminator, Field

from app.application.usecases.route_result_dto import RoutePointDto, RouteResultDto
from app.domain.value_objects.coordinate import Coordinate


class RouteRequestBase(BaseModel):
    """ルート生成リクエストの基底クラス (共通フィールド)"""

    current_lat: float = Field(
        description="現在地の緯度",
        ge=-90.0,
        le=90.0,
        examples=[35.6870958],
    )
    current_lng: float = Field(
        description="現在地の経度",
        ge=-180,
        le=180,
        examples=[139.8133963],
    )


class RouteRequestRandom(RouteRequestBase):
    """ランダムモードのルート生成リクエスト

    指定された半径内でランダムに目的地を選択します。
    """

    mode: Literal["random"] = Field(
        description="ルート生成モード",
        examples=["random"],
    )
    radius: int = Field(
        description="目的地を生成する半径 (メートル単位)",
        gt=0,
        le=40075000,  # 地球の赤道一周の長さ (メートル)
        examples=[5000],
    )


class RouteRequestDestination(RouteRequestBase):
    """目的地指定モードのルート生成リクエスト

    指定された座標を目的地として使用します。
    """

    mode: Literal["destination"] = Field(
        description="ルート生成モード",
        examples=["destination"],
    )
    destination_lat: float = Field(
        description="目的地の緯度",
        ge=-90.0,
        le=90.0,
        examples=[35.689487],
    )
    destination_lng: float = Field(
        description="目的地の経度",
        ge=-180,
        le=180,
        examples=[139.691706],
    )


# Discriminated Union: mode フィールドに基づいて自動的に適切なクラスを選択
RouteRequest = Annotated[
    RouteRequestRandom | RouteRequestDestination,
    Discriminator("mode"),
]


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
    heading: float | None = None
    name: str | None = None
    genre: str | None = None
    google_maps_url: str | None = None

    @classmethod
    def from_dto(cls, point: RoutePointDto) -> "MidPoint":
        """地点DTOからMidPointを作成

        Args:
            point: 地点DTO

        Returns:
            MidPoint: 中間地点モデル
        """
        coordinate = point.coordinate
        street_view_image = point.street_view_image
        lat, lng = coordinate.to_float_tuple()
        landmark = point.landmark
        google_maps_url = _build_google_maps_url(
            coordinate=coordinate,
            place_id=landmark.place_id if landmark is not None else None,
        )

        if street_view_image is None:
            return cls(
                latitude=lat,
                longitude=lng,
                name=landmark.display_name if landmark is not None else None,
                genre=_extract_genre(point),
                google_maps_url=google_maps_url,
            )

        image_lat, image_lng = street_view_image.metadata_coordinate.to_float_tuple()
        image_data_base64 = base64.b64encode(street_view_image.image_data).decode("utf-8")

        return cls(
            latitude=lat,
            longitude=lng,
            image_latitude=image_lat,
            image_longitude=image_lng,
            image_utf8=image_data_base64,
            heading=street_view_image.heading,
            name=landmark.display_name if landmark is not None else None,
            genre=_extract_genre(point),
            google_maps_url=google_maps_url,
        )


class RouteResponse(BaseModel):
    """ルート情報を表すモデル"""

    departure: Point
    destination: MidPoint
    midpoints: list[MidPoint]
    overview_polyline: str

    @classmethod
    def from_dto(cls, dto: RouteResultDto) -> "RouteResponse":
        """RouteResultDtoからAPIレスポンススキーマを作成

        Args:
            dto: ルート生成結果DTO

        Returns:
            RouteResponse: APIレスポンススキーマ
        """
        departure_lat, departure_lng = dto.departure.to_float_tuple()

        return cls(
            departure=Point(latitude=departure_lat, longitude=departure_lng),
            destination=MidPoint.from_dto(dto.destination),
            midpoints=[MidPoint.from_dto(point) for point in dto.midpoints],
            overview_polyline=dto.overview_polyline,
        )


def _extract_genre(point: RoutePointDto) -> str | None:
    """地点DTOから表示用ジャンルを取得する"""
    landmark = point.landmark
    if landmark is None:
        return None
    return landmark.primary_type or (landmark.types[0] if landmark.types else None)


def _build_google_maps_url(coordinate: Coordinate, place_id: str | None) -> str:
    """Google Mapsで地点詳細を開くURLを構築する"""
    lat, lng = coordinate.to_float_tuple()
    query = {"api": "1", "query": f"{lat},{lng}"}
    if place_id:
        query["query_place_id"] = place_id
    return f"https://www.google.com/maps/search/?{urlencode(query)}"
