"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging

from injector import inject
from pydantic import BaseModel, ConfigDict, Field
from tenacity import (
    before_sleep_log,
    retry,
    retry_if_exception_type,
    stop_after_attempt,
)

from app.application.gateway_interfaces.google_maps_gateway import GoogleMapsGateway
from app.config import ROUTE_GENERATION_MAX_RETRY_COUNT
from app.domain.exceptions import ExternalServiceValidationError, RouteGenerationError
from app.domain.services import coordinate_service, route_service
from app.domain.value_objects import (
    Coordinate,
    ImageSize,
    StreetViewImage,
)

logger = logging.getLogger(__name__)


class RouteResultDto(BaseModel):
    """ルート生成結果DTO

    Application層から返されるルート情報を表します。

    Attributes:
        departure: 出発地点の座標
        destination: 目的地の座標
        midpoints: 中間地点の座標リスト
        overview_polyline: ルートの概要ポリライン文字列
        midpoint_images: 中間地点の画像情報リスト
            ((座標, StreetViewImage)のリスト、順序を保持)
        destination_image: 目的地の画像情報
    """

    model_config = ConfigDict(frozen=True)

    departure: Coordinate = Field(description="出発地点の座標")
    destination: Coordinate = Field(description="目的地の座標")
    midpoints: list[Coordinate] = Field(description="中間地点の座標リスト")
    overview_polyline: str = Field(description="ルートの概要ポリライン文字列")
    midpoint_images: list[tuple[Coordinate, StreetViewImage]] = Field(
        description="中間地点の画像情報リスト ((座標, StreetViewImage)のリスト、順序を保持)"
    )
    destination_image: StreetViewImage | None = Field(default=None, description="目的地の画像情報")


class GenerateRouteUseCase:
    """ルート生成ユースケース"""

    @inject
    def __init__(
        self,
        google_maps_gateway: GoogleMapsGateway,
    ) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
        """
        self.google_maps_gateway = google_maps_gateway
        self.image_size = ImageSize(width=600, height=300)

    def execute(self, current_coordinate: Coordinate, radius_m: float) -> RouteResultDto:
        """ルートを生成する

        Street View画像が取得できない場合は、目的地を再生成してリトライします。
        最大リトライ回数を超えた場合はRouteGenerationErrorを発生させます。

        Args:
            current_coordinate: 現在地の座標
            radius_m: 半径 (メートル単位)

        Returns:
            RouteResultDto: ルート情報

        Raises:
            ExternalServiceError: 外部サービスエラーが発生した場合
            RouteGenerationError: リトライ回数を超えてもルート生成に失敗した場合
        """
        try:
            return self._attempt_route_generation(current_coordinate, radius_m)
        except ExternalServiceValidationError as e:
            raise RouteGenerationError(
                message="Street View画像が取得可能なルートが見つかりませんでした",
                retry_count=ROUTE_GENERATION_MAX_RETRY_COUNT,
            ) from e

    @retry(
        stop=stop_after_attempt(ROUTE_GENERATION_MAX_RETRY_COUNT),
        retry=retry_if_exception_type(ExternalServiceValidationError),
        before_sleep=before_sleep_log(logger, logging.INFO),
        reraise=True,
    )
    def _attempt_route_generation(
        self, current_coordinate: Coordinate, radius_m: float
    ) -> RouteResultDto:
        """ルート生成を試みる

        Street View画像が取得できない場合は、目的地を再生成してリトライします。
        最大リトライ回数を超えた場合はRouteGenerationErrorを発生させます。

        Args:
            current_coordinate: 現在地の座標
            radius_m: 半径 (メートル単位)

        Returns:
            RouteResultDto: ルート情報

        Raises:
            ExternalServiceValidationError: Street View画像が取得できない場合
        """
        # 目的地の座標計算
        destination_coordinate = coordinate_service.generate_random_point(
            current_coordinate, radius_m
        )
        destination_image = self._get_street_view_image_data(
            destination_coordinate,
            self.image_size,
        )

        # ルート情報取得
        route_coordinates, overview_polyline = self.google_maps_gateway.get_directions(
            current_coordinate, destination_coordinate
        )

        # 中間地点の座標計算と画像取得
        midpoint_coordinate = route_service.calculate_midpoint(route_coordinates)
        midpoint_image = self._get_street_view_image_data(
            midpoint_coordinate,
            self.image_size,
        )

        return RouteResultDto(
            departure=current_coordinate,
            destination=destination_coordinate,
            midpoints=[midpoint_coordinate],
            overview_polyline=overview_polyline,
            midpoint_images=[(midpoint_coordinate, midpoint_image)],
            destination_image=destination_image,
        )

    def _get_street_view_image_data(
        self, coordinate: Coordinate, image_size: ImageSize
    ) -> StreetViewImage:
        """Street View Image Metadata APIを使用して画像のメタデータを取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            StreetViewImage: Street View画像情報

        Raises:
            ExternalServiceValidationError: Street View画像が取得できない場合
        """
        metadata_coordinate = self._get_validated_metadata(coordinate)
        image_content = self.google_maps_gateway.get_street_view_image(
            coordinate=metadata_coordinate,
            image_size=image_size,
        )
        return StreetViewImage(
            metadata_coordinate=metadata_coordinate,
            original_coordinate=coordinate,
            image_data=image_content,
        )

    def _get_validated_metadata(self, coordinate: Coordinate) -> Coordinate:
        """メタデータを取得し、検証する

        Args:
            coordinate: 座標

        Returns:
            Coordinate: メタデータから取得した画像の実際の座標

        Raises:
            ExternalServiceValidationError: Street View画像が取得できない場合
        """
        try:
            metadata = self.google_maps_gateway.get_street_view_metadata(coordinate)
        except ExternalServiceValidationError as e:
            logger.error(f"Street View metadata validation failed: {e}")
            raise ExternalServiceValidationError(str(e), service_name="Street View API") from e

        if metadata.status != "OK":
            logger.error(
                f"Street View metadata API returned a non-OK status for a requested location. "
                f"Status: {metadata.status}"
            )
            raise ExternalServiceValidationError(
                f"Street View metadata unavailable: {metadata.status}.",
                service_name="Street View API",
            )

        location_coordinate = metadata.location
        if location_coordinate is None:
            # このケースは通常発生しない(Gateway実装のバリデーションで防がれる)
            logger.error("Street View metadata has OK status but location is None")
            raise ExternalServiceValidationError(
                "Street View metadata incomplete: location is None",
                service_name="Street View API",
            )

        logger.info(
            f"Actual Image Location: Latitude {location_coordinate.latitude}, "
            f"Longitude {location_coordinate.longitude}"
        )

        return location_coordinate
