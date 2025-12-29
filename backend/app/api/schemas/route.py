"""ルートAPIスキーマ定義"""

import base64

from pydantic import BaseModel

from app.application.usecases.generate_route_usecase import RouteResultDto
from app.domain.value_objects.coordinate import Coordinate
from app.domain.value_objects.street_view_image import StreetViewImage


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

    @classmethod
    def from_coordinate(
        cls, coordinate: Coordinate, street_view_image: StreetViewImage | None
    ) -> "MidPoint":
        """座標と画像情報からMidPointを作成

        Args:
            coordinate: 座標
            street_view_image: ストリートビュー画像 (存在しない場合はNone)

        Returns:
            MidPoint: 中間地点モデル
        """
        lat, lng = coordinate.to_float_tuple()

        if street_view_image is None:
            return cls(latitude=lat, longitude=lng)

        image_lat, image_lng = street_view_image.metadata_coordinate.to_float_tuple()
        image_data_base64 = base64.b64encode(street_view_image.image_data).decode("utf-8")

        return cls(
            latitude=lat,
            longitude=lng,
            image_latitude=image_lat,
            image_longitude=image_lng,
            image_utf8=image_data_base64,
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
        midpoint_images_dict = dict[Coordinate, StreetViewImage](dto.midpoint_images)
        midpoint_list = [
            MidPoint.from_coordinate(coord, midpoint_images_dict.get(coord))
            for coord in dto.midpoints
        ]

        departure_lat, departure_lng = dto.departure.to_float_tuple()

        return cls(
            departure=Point(latitude=departure_lat, longitude=departure_lng),
            destination=MidPoint.from_coordinate(dto.destination, dto.destination_image),
            midpoints=midpoint_list,
            overview_polyline=dto.overview_polyline,
        )
