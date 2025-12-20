"""ルートAPIスキーマ定義"""

from pydantic import BaseModel

from app.application.dto.route_dto import RouteResultDto


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
                        latitude=midpoint_coordinate.latitude.value,
                        longitude=midpoint_coordinate.longitude.value,
                        image_latitude=image_coordinate.latitude.value,
                        image_longitude=image_coordinate.longitude.value,
                        image_utf8=image_data,
                    )
                )
            else:
                midpoint_list.append(
                    MidPoint(
                        latitude=midpoint_coordinate.latitude.value,
                        longitude=midpoint_coordinate.longitude.value,
                    )
                )

        # 目的地の画像情報を取得
        destination_image_lat = None
        destination_image_lng = None
        destination_image_data = None
        if dto.destination_image:
            image_coordinate, image_data = dto.destination_image
            destination_image_lat = image_coordinate.latitude.value
            destination_image_lng = image_coordinate.longitude.value
            destination_image_data = image_data

        return cls(
            departure=Point(
                latitude=dto.departure.latitude.value, longitude=dto.departure.longitude.value
            ),
            destination=MidPoint(
                latitude=dto.destination.latitude.value,
                longitude=dto.destination.longitude.value,
                image_latitude=destination_image_lat,
                image_longitude=destination_image_lng,
                image_utf8=destination_image_data,
            ),
            midpoints=midpoint_list,
            overview_polyline=dto.overview_polyline,
        )
