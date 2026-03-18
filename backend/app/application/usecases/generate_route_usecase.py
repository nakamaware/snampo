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
    StreetViewImageFetchService,
)
from app.config import (
    LANDMARK_SEARCH_MAX_CALLS,
    LANDMARK_SEARCH_TARGET_COUNT,
    MIDPOINT_MIN_SEARCH_RADIUS_M,
)
from app.domain.exceptions import (
    ExternalServiceError,
    ExternalServiceValidationError,
    RouteGenerationError,
)
from app.domain.services import coordinate_service
from app.domain.services.mission_point_calculator import MissionPointCalculator
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
        street_view_image_fetch_service: StreetViewImageFetchService,
    ) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
            landmark_search_service: ランドマーク検索サービス
            landmark_selector: 画像付きランドマーク選択サービス
            street_view_image_fetch_service: Street View画像取得サービス
        """
        self.google_maps_gateway = google_maps_gateway
        self.landmark_search_service = landmark_search_service
        self.landmark_selector = landmark_selector
        self.street_view_image_fetch_service = street_view_image_fetch_service

    def execute(
        self,
        current_coordinate: Coordinate,
        radius_m: int | None = None,
        destination_coordinate: Coordinate | None = None,
    ) -> RouteResultDto:
        """ルートを生成する

        2つのモードをサポート:
        - ランダムモード: radius_m を指定し、目的地を自動選択
        - 目的地指定モード: destination_coordinate を指定

        アプローチ:
        1. 目的地のランドマークを決定 (ランダムモードの場合)
        2. 必要なmission地点数を計算(距離に応じて)
        3. ルートを等分割して複数の中間地点候補を生成
        4. 各中間地点付近でランドマークを検索
        5. 初期地点→目的地のルートを取得(waypoints=[地点1, 地点2, ...])

        Args:
            current_coordinate: 現在地の座標
            radius_m: 半径 (メートル単位、ランダムモード用)
            destination_coordinate: 目的地の座標 (目的地指定モード用)

        Returns:
            RouteResultDto: ルート情報
        """
        if destination_coordinate is None and radius_m is None:
            raise ValueError("radius_m または destination_coordinate のいずれかを指定してください")
        if destination_coordinate is not None and radius_m is not None:
            raise ValueError("radius_m と destination_coordinate は同時に指定できません")

        try:
            destination_image: StreetViewImage | None = None

            # 1. 目的地の決定
            if destination_coordinate is not None:
                # 目的地指定モード: 指定された座標をそのまま使用し、Street View画像を取得
                logger.info("Using specified destination coordinate")
                destination_image = self.street_view_image_fetch_service.get_image(
                    destination_coordinate
                )
                logger.info("Successfully fetched Street View image for specified destination")
            else:
                # ランダムモード: ランドマーク検索で目的地を決定
                logger.info("Using random mode to determine destination")
                if radius_m is None:
                    raise ValueError(
                        "radius_m または destination_coordinate のいずれかを指定してください"
                    )

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
                logger.info("Successfully fetched Street View image for random destination")

            # 2. 必要なmission地点数を計算
            required_mission_points = MissionPointCalculator.calculate_mission_point_count(radius_m)
            midpoint_target_count = max(required_mission_points - 1, 0)
            logger.info(
                "Required mission points(total): %s, midpoint targets: %s for radius %sm",
                required_mission_points,
                midpoint_target_count,
                radius_m,
            )

            # 中間地点の検索半径を決定
            if radius_m is None:
                # 目的地指定モード: 現在地〜目的地の距離から計算
                radius_m = int(
                    coordinate_service.calculate_distance(
                        current_coordinate, destination_coordinate
                    )
                )

            # 3. ルートを等分割して複数の中間地点候補を生成
            candidate_coordinates = coordinate_service.divide_route_into_segments(
                start=current_coordinate,
                end=destination_coordinate,
                num_segments=midpoint_target_count,
            )

            # 4. 各中間地点付近でランドマーク検索
            midpoint_results = []
            midpoint_search_radius = max(MIDPOINT_MIN_SEARCH_RADIUS_M, radius_m // 4)

            for i, candidate_coord in enumerate(candidate_coordinates, 1):
                logger.info(f"Searching landmarks for mission point {i}/{midpoint_target_count}")

                # 各候補地点周辺でランドマーク検索
                landmarks = self.google_maps_gateway.search_landmarks_nearby(
                    coordinate=candidate_coord,
                    radius=midpoint_search_radius,
                    rank_preference="DISTANCE",
                )

                if landmarks:
                    # 画像付きランドマークを選択
                    try:
                        _, image = self.landmark_selector.select(landmarks)
                        midpoint_results.append((image.metadata_coordinate, image))
                        logger.info(f"Mission point {i} found at {image.metadata_coordinate}")
                    except ExternalServiceValidationError:
                        logger.warning(f"No image available for mission point {i}")
                else:
                    logger.warning(f"No landmarks found for mission point {i}")

            # 必要数に満たない場合の警告
            if len(midpoint_results) < midpoint_target_count:
                logger.warning(
                    f"Only {len(midpoint_results)}/{midpoint_target_count} "
                    "mission points could be generated"
                )

            # 5. ルート全体を取得(waypointsとして全midpointを渡す)
            midpoint_coords = [coord for coord, _ in midpoint_results]
            _, overview_polyline = self.google_maps_gateway.get_directions(
                origin=current_coordinate,
                destination=destination_coordinate,
                waypoints=midpoint_coords,  # 複数のwaypointsを渡す
            )

            # デバッグ用ログ: 生成されたルートの中間地点と画像の数を出力
            logger.info(
                "RouteResultDto midpoints count=%s, midpoint_images count=%s, total missions=%s",
                len(midpoint_coords),
                len(midpoint_results),
                len(midpoint_coords) + (1 if destination_image is not None else 0),
            )

            return RouteResultDto(
                departure=current_coordinate,
                destination=destination_coordinate,
                midpoints=midpoint_coords,
                overview_polyline=overview_polyline,
                midpoint_images=midpoint_results,
                destination_image=destination_image,
            )
        except (ExternalServiceValidationError, ExternalServiceError, ValueError) as e:
            raise RouteGenerationError(
                message=(
                    "ランドマークが見つからないか、"
                    "Street View画像が取得可能なルートが見つかりませんでした"
                ),
            ) from e
