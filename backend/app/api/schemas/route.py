"""ルートAPIスキーマ定義"""

from pydantic import BaseModel

from app.application.dto.route_dto import RouteResultDto
from app.domain.value_objects import Latitude, Longitude


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
        # 中間地点の画像情報を取得
        midpoint_list: list[MidPoint] = []
        for midpoint_coordinate in dto.midpoints:
            image_info = dto.midpoint_images.get(midpoint_coordinate)
            if image_info:
                image_coordinate, image_data = image_info
                midpoint_list.append(
                    MidPoint(
                        latitude=midpoint_coordinate.latitude,
                        longitude=midpoint_coordinate.longitude,
                        image_latitude=image_coordinate.latitude,
                        image_longitude=image_coordinate.longitude,
                        image_utf8=image_data,
                    )
                )
            else:
                midpoint_list.append(
                    MidPoint(
                        latitude=midpoint_coordinate.latitude,
                        longitude=midpoint_coordinate.longitude,
                    )
                )

        # 目的地の画像情報を取得
        destination_image_lat = None
        destination_image_lng = None
        destination_image_data = None
        if dto.destination_image:
            image_coordinate, image_data = dto.destination_image
            destination_image_lat = image_coordinate.latitude
            destination_image_lng = image_coordinate.longitude
            destination_image_data = image_data

        return cls(
            departure=Point(latitude=dto.departure.latitude, longitude=dto.departure.longitude),
            destination=MidPoint(
                latitude=dto.destination.latitude,
                longitude=dto.destination.longitude,
                image_latitude=destination_image_lat,
                image_longitude=destination_image_lng,
                image_utf8=destination_image_data,
            ),
            midpoints=midpoint_list,
            overview_polyline=dto.overview_polyline,
        )
