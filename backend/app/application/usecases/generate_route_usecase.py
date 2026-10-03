"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging
import random

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
    MIDPOINT_DEDUP_MIN_DISTANCE_TO_DESTINATION_M,
    MIDPOINT_MIN_GAP_RATIO,
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
        # 中間地点の配置に使う乱数生成器。テストではシード固定のものに差し替える
        self.rng = random.Random()  # noqa: S311 - 配置のゆらぎ用で暗号用途ではない

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
        4. ルート上に最低間隔を保ちつつランダムな間隔で中間地点候補を生成
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
            used_place_ids: set[str] = set()

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
                used_place_ids.add(destination_landmark.place_id)
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
            min_gap_m = 0.0
            if midpoint_target_count > 0:
                route_coordinates, _ = self.google_maps_gateway.get_directions(
                    origin=current_coordinate,
                    destination=destination_coordinate,
                    waypoints=None,
                )
                candidate_coordinates = coordinate_service.divide_route_into_segments(
                    route_coordinates=route_coordinates,
                    num_segments=midpoint_target_count,
                    min_gap_ratio=MIDPOINT_MIN_GAP_RATIO,
                    rng=self.rng,
                )
                if candidate_coordinates:
                    route_length_m = coordinate_service.calculate_route_length(route_coordinates)
                    min_gap_m = (
                        route_length_m / (midpoint_target_count + 1) * MIDPOINT_MIN_GAP_RATIO
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
                    filtered_landmarks = self._filter_midpoint_landmark_candidates(
                        landmarks, used_place_ids, destination_coordinate
                    )
                    if not filtered_landmarks:
                        logger.warning(
                            (
                                "All landmark candidates for mission point %s/%s were "
                                "filtered as duplicates of the destination or prior midpoints"
                            ),
                            i,
                            midpoint_target_count,
                        )
                        continue
                    adopted_coordinates = [
                        current_coordinate,
                        destination_coordinate,
                        *(point.coordinate for point in midpoint_results),
                    ]
                    ordered_landmarks, spaced_place_ids = self._order_by_spacing(
                        filtered_landmarks, adopted_coordinates, min_gap_m
                    )
                    try:
                        landmark, image = self.landmark_selector.select(ordered_landmarks)
                        if landmark.place_id not in spaced_place_ids:
                            logger.warning(
                                (
                                    "No landmark for mission point %s/%s satisfies the "
                                    "minimum gap of %.0fm; using the farthest candidate"
                                ),
                                i,
                                midpoint_target_count,
                                min_gap_m,
                            )
                        used_place_ids.add(landmark.place_id)
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

    @staticmethod
    def _order_by_spacing(
        landmarks: list[Landmark],
        adopted_coordinates: list[Coordinate],
        min_gap_m: float,
    ) -> tuple[list[Landmark], set[str]]:
        """既存地点から最低間隔以上離れた候補を優先する順に並べ替える

        最低間隔を満たす候補は元の順 (基準点に近い順) のまま先頭に置き、
        満たさない候補は既存地点から遠い順に後ろへ並べます。
        こうすることで、条件を満たす候補がない (または画像が取れない) 場合も
        既存地点から最も離れた候補が選ばれます。

        Returns:
            (並べ替えた候補リスト, 最低間隔を満たす候補の place_id 集合)
        """
        spaced: list[Landmark] = []
        too_close: list[tuple[float, Landmark]] = []
        for lm in landmarks:
            nearest_m = min(
                coordinate_service.calculate_distance(lm.coordinate, coordinate)
                for coordinate in adopted_coordinates
            )
            if nearest_m >= min_gap_m:
                spaced.append(lm)
            else:
                too_close.append((nearest_m, lm))
        too_close.sort(key=lambda item: item[0], reverse=True)
        return spaced + [lm for _, lm in too_close], {lm.place_id for lm in spaced}

    @staticmethod
    def _filter_midpoint_landmark_candidates(
        landmarks: list[Landmark],
        used_place_ids: set[str],
        destination_coordinate: Coordinate,
    ) -> list[Landmark]:
        """中間地点用に、目的地・既採用地点と重複するランドマークを除いた候補を返す"""
        out: list[Landmark] = []
        for lm in landmarks:
            if lm.place_id in used_place_ids:
                continue
            if (
                coordinate_service.calculate_distance(lm.coordinate, destination_coordinate)
                < MIDPOINT_DEDUP_MIN_DISTANCE_TO_DESTINATION_M
            ):
                continue
            out.append(lm)
        return out
