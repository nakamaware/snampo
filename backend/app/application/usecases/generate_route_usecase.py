"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging

from injector import inject

from app.application.gateway_interfaces.google_maps_gateway import GoogleMapsGateway
from app.application.services import (
    LandmarkImageSelectionService,
    LandmarkSearchService,
    StreetViewImageFetchService,
)
from app.application.usecases.route_result_dto import RoutePointDto, RouteResultDto
from app.config import (
    DIRECTIONS_API_MAX_WAYPOINTS,
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
from app.domain.services.mission_point_calculation_service import calculate_mission_point_count
from app.domain.value_objects import (
    Coordinate,
    Landmark,
    StreetViewImage,
)

logger = logging.getLogger(__name__)


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
        3. 現在地→目的地のルートを先に取得
        4. ルート上を等分割して複数の中間地点候補を生成
        5. 各中間地点付近でランドマークを検索
        6. 初期地点→目的地のルートを取得(waypoints=[地点1, 地点2, ...])

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
            destination_landmark: Landmark | None = None

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

                destination_landmark, destination_image = self.landmark_selector.select(
                    destination_landmarks, shuffle=True
                )
                destination_coordinate = destination_image.metadata_coordinate
                logger.info("Successfully fetched Street View image for random destination")

            # 2. 目的地指定モードでは、現在地〜目的地の距離から半径を計算
            if radius_m is None:
                radius_m = int(
                    coordinate_service.calculate_distance(
                        current_coordinate, destination_coordinate
                    )
                )

            # 3. 必要なmission地点数を計算
            required_midpoint_count = calculate_mission_point_count(radius_m)
            midpoint_target_count = min(required_midpoint_count, DIRECTIONS_API_MAX_WAYPOINTS)
            if midpoint_target_count != required_midpoint_count:
                logger.info(
                    (
                        "Required midpoint count %s exceeded limit, "
                        "capped to %s due to waypoint constraint"
                    ),
                    required_midpoint_count,
                    midpoint_target_count,
                )
            logger.info(
                (
                    "Required midpoint count: %s, capped midpoint count: %s, "
                    "total missions: %s for radius %sm"
                ),
                required_midpoint_count,
                midpoint_target_count,
                midpoint_target_count + 1,
                radius_m,
            )

            # 4. 現在地→目的地の実ルート上から複数の中間地点候補を生成
            candidate_coordinates = []
            if midpoint_target_count > 0:
                route_coordinates, _ = self.google_maps_gateway.get_directions(
                    origin=current_coordinate,
                    destination=destination_coordinate,
                    waypoints=None,
                )
                candidate_coordinates = coordinate_service.divide_route_into_segments(
                    route_coordinates=route_coordinates,
                    num_segments=midpoint_target_count,
                )

            # 5. 各中間地点付近でランドマーク検索
            midpoint_results: list[RoutePointDto] = []
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
                        landmark, image = self.landmark_selector.select(landmarks)
                        midpoint_results.append(
                            RoutePointDto(
                                coordinate=image.metadata_coordinate,
                                street_view_image=image,
                                landmark=landmark,
                            )
                        )
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

            # 6. ルート全体を取得(waypointsとして全midpointを渡す)
            midpoint_coords = [point.coordinate for point in midpoint_results]
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
                destination=RoutePointDto(
                    coordinate=destination_coordinate,
                    street_view_image=destination_image,
                    landmark=destination_landmark,
                ),
                overview_polyline=overview_polyline,
                midpoints=midpoint_results,
            )
        except (ExternalServiceValidationError, ExternalServiceError, ValueError) as e:
            raise RouteGenerationError(
                message=(
                    "ランドマークが見つからないか、"
                    "Street View画像が取得可能なルートが見つかりませんでした"
                ),
            ) from e
