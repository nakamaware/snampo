"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging
import random

from injector import inject
from pydantic import BaseModel, ConfigDict, Field

from app.application.gateway_interfaces.google_maps_gateway import GoogleMapsGateway
from app.application.services import LandmarkSearchService
from app.config import (
    LANDMARK_SEARCH_MAX_CALLS,
    LANDMARK_SEARCH_TARGET_COUNT,
)
from app.domain.exceptions import (
    ExternalServiceError,
    ExternalServiceTimeoutError,
    ExternalServiceValidationError,
    RouteGenerationError,
)
from app.domain.services import coordinate_service
from app.domain.value_objects import (
    Coordinate,
    ImageSize,
    StreetViewImage,
)
from app.infrastructure.mappers import polyline_mapper

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
        landmark_search_service: LandmarkSearchService,
    ) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
            landmark_search_service: ランドマーク検索サービス
        """
        self.google_maps_gateway = google_maps_gateway
        self.landmark_search_service = landmark_search_service
        self.image_size = ImageSize(width=600, height=300)

    def execute(self, current_coordinate: Coordinate, radius_m: int) -> RouteResultDto:
        """ルートを生成する

        アプローチ:
        1. 目的地のランドマークを決定
        2. 中間地点付近でランドマークを検索
        3. 初期地点→中間地点、中間地点→目的地の2つのルートを取得し、結合

        Args:
            current_coordinate: 現在地の座標
            radius_m: 半径 (メートル単位)

        Returns:
            RouteResultDto: ルート情報

        Raises:
            ExternalServiceError: 外部サービスエラーが発生した場合
            RouteGenerationError: ルート生成に失敗した場合
        """
        try:
            # 1. 目的地のランドマーク検索 (指定距離付近のランドマークを検索)
            destination_landmarks = self.landmark_search_service.search_landmarks(
                center=current_coordinate,
                target_distance_m=radius_m,
                target_count=LANDMARK_SEARCH_TARGET_COUNT,
                max_calls=LANDMARK_SEARCH_MAX_CALLS,
            )
            logger.info(f"Find {len(destination_landmarks)} landmarks around destination")
            if not destination_landmarks:
                raise ExternalServiceValidationError(
                    "指定距離付近にランドマークが見つかりませんでした",
                    service_name="Places API",
                )

            destination_landmark = random.choice(destination_landmarks)  # noqa: S311 (ただのランダムの選択なので問題なし)
            logger.info(f"Destination landmark: {destination_landmark}")

            destination_image = self._get_street_view_image_data(
                destination_landmark.coordinate,
                self.image_size,
            )

            # 2. 中間地点付近のランドマーク検索
            midpoint_coordinate = coordinate_service.calculate_geodesic_midpoint(
                current_coordinate, destination_landmark.coordinate
            )
            midpoint_search_radius = self._calculate_midpoint_search_radius(radius_m)
            midpoint_landmarks = self.google_maps_gateway.search_landmarks_nearby(
                coordinate=midpoint_coordinate,
                radius=midpoint_search_radius,
                rank_preference="DISTANCE",
            )
            logger.info(f"Find {len(midpoint_landmarks)} landmarks around midpoint")
            if not midpoint_landmarks:
                raise ExternalServiceValidationError(
                    "中間地点付近にランドマークが見つかりませんでした",
                    service_name="Places API",
                )

            midpoint_landmark = midpoint_landmarks[0]  # 一番近いランドマークを使用
            midpoint_coordinate = midpoint_landmark.coordinate
            logger.info(f"Midpoint landmark: {midpoint_landmark}")

            midpoint_image = self._get_street_view_image_data(
                midpoint_coordinate,
                self.image_size,
            )

            # 3. 現在地→中間地点、中間地点→目的地の2つのルートを取得し、結合
            _, polyline_1 = self.google_maps_gateway.get_directions(
                current_coordinate, midpoint_coordinate
            )
            _, polyline_2 = self.google_maps_gateway.get_directions(
                midpoint_coordinate, destination_landmark.coordinate
            )
            merged_polyline = polyline_mapper.merge_polylines(polyline_1, polyline_2)

            return RouteResultDto(
                departure=current_coordinate,
                destination=destination_landmark.coordinate,
                midpoints=[midpoint_coordinate],
                overview_polyline=merged_polyline,
                midpoint_images=[(midpoint_coordinate, midpoint_image)],
                destination_image=destination_image,
            )
        except (ExternalServiceValidationError, ValueError) as e:
            raise RouteGenerationError(
                message=(
                    "ランドマークが見つからないか、"
                    "Street View画像が取得可能なルートが見つかりませんでした"
                ),
            ) from e

    def _calculate_midpoint_search_radius(self, radius_m: int) -> int:
        """中間地点の検索半径を計算

        以下のような計算になる。
        radius_m = 500m -> 125m
        radius_m = 1000m -> 250m
        radius_m = 1500m -> 300m
        radius_m = 2000m -> 300m

        Args:
            radius_m: 半径 (メートル単位)

        Returns:
            int: 中間地点の検索半径
        """
        return max(300, radius_m // 4)

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
        # 対象座標にストリートビューが存在するかを確認するためにメタデータを取得
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

        metadata_coordinate = metadata.location
        if metadata_coordinate is None:
            # NOTE: このケースは通常発生しない (Gateway実装のバリデーションで防がれる)
            logger.error("Street View metadata has OK status but location is None")
            raise ExternalServiceValidationError(
                "Street View metadata incomplete: location is None",
                service_name="Street View API",
            )

        # ストリートビュー画像を取得
        try:
            image_content = self.google_maps_gateway.get_street_view_image(
                coordinate=metadata_coordinate,
                image_size=image_size,
            )
        except ExternalServiceTimeoutError as e:
            logger.error(f"Street View image timeout: {e}")
            raise ExternalServiceTimeoutError(str(e), service_name="Street View API") from e
        except ExternalServiceError as e:
            logger.error(f"Street View image error: {e}")
            raise ExternalServiceError(str(e), service_name="Street View API") from e

        return StreetViewImage(
            metadata_coordinate=metadata_coordinate,
            original_coordinate=coordinate,
            image_data=image_content,
        )
