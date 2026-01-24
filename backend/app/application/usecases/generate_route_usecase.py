"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging

from injector import inject
from pydantic import BaseModel, ConfigDict, Field

from app.application.gateway_interfaces.google_maps_gateway import GoogleMapsGateway
from app.application.services import (
    LandmarkImageSelectionService,
    LandmarkSearchService,
)
from app.config import (
    LANDMARK_SEARCH_MAX_CALLS,
    LANDMARK_SEARCH_TARGET_COUNT,
    MIDPOINT_MIN_SEARCH_RADIUS_M,
)
from app.domain.exceptions import (
    ExternalServiceValidationError,
    RouteGenerationError,
)
from app.domain.services import coordinate_service
from app.domain.value_objects import (
    Coordinate,
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
        landmark_search_service: LandmarkSearchService,
        landmark_selector: LandmarkImageSelectionService,
    ) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
            landmark_search_service: ランドマーク検索サービス
            landmark_selector: 画像付きランドマーク選択サービス
        """
        self.google_maps_gateway = google_maps_gateway
        self.landmark_search_service = landmark_search_service
        self.landmark_selector = landmark_selector

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
            # 1. 目的地のランドマーク検索
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

            _, destination_image = self.landmark_selector.select(
                destination_landmarks, shuffle=True
            )
            destination_coordinate = destination_image.metadata_coordinate

            # 2. 中間地点付近のランドマーク検索
            midpoint_coordinate = coordinate_service.calculate_geodesic_midpoint(
                current_coordinate, destination_coordinate
            )
            midpoint_search_radius = max(MIDPOINT_MIN_SEARCH_RADIUS_M, radius_m // 4)
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

            _, midpoint_image = self.landmark_selector.select(midpoint_landmarks, shuffle=False)
            midpoint_coordinate = midpoint_image.metadata_coordinate

            # 3. 現在地→目的地のルートを取得
            _, overview_polyline = self.google_maps_gateway.get_directions(
                current_coordinate,
                destination_coordinate,
                waypoints=[midpoint_coordinate],
            )

            return RouteResultDto(
                departure=current_coordinate,
                destination=destination_coordinate,
                midpoints=[midpoint_coordinate],
                overview_polyline=overview_polyline,
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
