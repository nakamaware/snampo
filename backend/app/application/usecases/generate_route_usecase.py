"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging

from fastapi import HTTPException
from injector import inject

from app.application.dto.route_dto import RouteResultDto
from app.application.ports.google_maps_gateway import GoogleMapsGateway
from app.application.services.street_view_service import StreetViewService
from app.domain.services import coordinate_service, route_service
from app.domain.value_objects import Coordinate, ImageHeight, ImageSize, ImageWidth

logger = logging.getLogger(__name__)


class GenerateRouteUseCase:
    """ルート生成ユースケース"""

    @inject
    def __init__(
        self,
        google_maps_gateway: GoogleMapsGateway,
        street_view_service: StreetViewService,
    ) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
            street_view_service: Street Viewサービス
        """
        self.google_maps_gateway = google_maps_gateway
        self.street_view_service = street_view_service

    def execute(self, current_lat: float, current_lng: float, radius_m: float) -> RouteResultDto:
        """ルートを生成する

        Args:
            current_lat: 現在の緯度
            current_lng: 現在の経度
            radius_m: 半径 (メートル単位)

        Returns:
            RouteResultDto: ルート情報
        """
        # 座標値オブジェクトに変換
        current_coordinate = Coordinate(latitude=current_lat, longitude=current_lng)

        # ルート検索
        destination_coordinate, route_coordinates, overview_polyline = (
            self._fetch_route_coordinates(current_coordinate, radius_m)
        )

        # 中間地点の情報取得
        midpoint_coordinate, midpoint_images = self._fetch_midpoint_image(route_coordinates)

        # 最終地点の情報取得
        destination_image = self._fetch_destination_image(destination_coordinate)

        # RouteResultを返す
        return RouteResultDto(
            departure=current_coordinate,
            destination=destination_coordinate,
            midpoints=[midpoint_coordinate],
            overview_polyline=overview_polyline,
            midpoint_images=midpoint_images,
            destination_image=destination_image,
        )

    def _fetch_route_coordinates(
        self, current_coordinate: Coordinate, radius_m: float
    ) -> tuple[Coordinate, list[Coordinate], str]:
        """ルート検索を実行

        Args:
            current_coordinate: 現在地の座標
            radius_m: 半径 (メートル単位)

        Returns:
            tuple[Coordinate, list[Coordinate], str]:
                (目的地座標, ルート座標リスト, overview_polyline文字列)
        """
        destination_coordinate = coordinate_service.generate_random_point(
            current_coordinate, radius_m
        )
        route_coordinates, overview_polyline = self.google_maps_gateway.get_directions(
            current_coordinate, destination_coordinate
        )

        return destination_coordinate, route_coordinates, overview_polyline

    def _fetch_midpoint_image(
        self, route_coordinates: list[Coordinate]
    ) -> tuple[Coordinate, dict[Coordinate, tuple[Coordinate, str]]]:
        """中間地点の画像情報を取得

        Args:
            route_coordinates: ルート座標リスト

        Returns:
            tuple[Coordinate, dict[Coordinate, tuple[Coordinate, str]]]:
                (中間地点座標, 中間地点画像情報)
        """
        midpoint_coordinate = route_service.calculate_midpoint(route_coordinates)
        midpoint_images: dict[Coordinate, tuple[Coordinate, str]] = {}
        try:
            # 画像サイズを値オブジェクトに変換
            image_size = ImageSize(
                width=ImageWidth(value=600),
                height=ImageHeight(value=300),
            )
            photo_data = self.street_view_service.get_street_view_image_data(
                midpoint_coordinate.latitude,
                midpoint_coordinate.longitude,
                image_size,
            )
            midpoint_images[midpoint_coordinate] = (
                photo_data.metadata_coordinate,
                photo_data.image_data,
            )
        except HTTPException:
            # Street View画像が取得できない場合は画像情報なしで続行
            logger.warning(
                f"Failed to fetch Street View image for midpoint at "
                f"{self.google_maps_gateway.coordinate_to_lat_lng_string(midpoint_coordinate)}"
            )
        return midpoint_coordinate, midpoint_images

    def _fetch_destination_image(
        self, destination_coordinate: Coordinate
    ) -> tuple[Coordinate, str] | None:
        """最終地点の画像情報を取得

        Args:
            destination_coordinate: 目的地の座標

        Returns:
            tuple[Coordinate, str] | None: 最終地点の画像情報(取得できない場合はNone)
        """
        try:
            # 画像サイズを値オブジェクトに変換
            image_size = ImageSize(
                width=ImageWidth(value=600),
                height=ImageHeight(value=300),
            )
            destination_photo_data = self.street_view_service.get_street_view_image_data(
                destination_coordinate.latitude,
                destination_coordinate.longitude,
                image_size,
            )
            return (
                destination_photo_data.metadata_coordinate,
                destination_photo_data.image_data,
            )
        except HTTPException:
            # Street View画像が取得できない場合は画像情報なしで続行
            logger.warning(
                f"Failed to fetch Street View image for destination at "
                f"{self.google_maps_gateway.coordinate_to_lat_lng_string(destination_coordinate)}"
            )
            return None
