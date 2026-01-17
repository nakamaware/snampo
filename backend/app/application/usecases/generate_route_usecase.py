"""ルート生成ユースケース

ルート生成のビジネスロジックをオーケストレーションします。
"""

import logging
import random

from injector import inject
from pydantic import BaseModel, ConfigDict, Field
from tenacity import Retrying, retry_if_exception_type, stop_after_attempt

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
    Landmark,
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
        # TODO: 全体的にロジックがわかりづらくなっているのでリファクタリングする
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

            # 画像が取得できる目的地を探す (ランダム順で試行)
            random.shuffle(destination_landmarks)
            _, destination_image = self._select_landmark_with_image(destination_landmarks)
            destination_coordinate = destination_image.metadata_coordinate

            # 2. 中間地点付近のランドマーク検索
            midpoint_coordinate = coordinate_service.calculate_geodesic_midpoint(
                current_coordinate, destination_coordinate
            )
            midpoint_search_radius = max(300, radius_m // 4)  # (300m, 最大半径の1/4) の最大値
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

            # 画像が取得できる中間地点を探す (距離順で試行)
            _, midpoint_image = self._select_landmark_with_image(midpoint_landmarks)
            midpoint_coordinate = midpoint_image.metadata_coordinate

            # 3. 現在地→目的地のルートを取得 (中間地点をwaypointsとして指定)
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

    def _select_landmark_with_image(
        self,
        candidates: list[Landmark],
    ) -> tuple[Landmark, StreetViewImage]:
        """画像が取得できるランドマークを選択する

        候補リストを順番に試行し、画像が取得できたランドマークを返す。

        Args:
            candidates: ランドマーク候補リスト

        Returns:
            (ランドマーク, 画像) のタプル

        Raises:
            ExternalServiceValidationError: すべての候補で画像取得に失敗した場合
        """
        for attempt in Retrying(
            stop=stop_after_attempt(len(candidates)),
            retry=retry_if_exception_type(ExternalServiceValidationError),
            reraise=True,
        ):
            with attempt:
                idx = attempt.retry_state.attempt_number - 1
                candidate = candidates[idx]

                try:
                    image = self._get_street_view_image_data(
                        candidate.coordinate,
                        self.image_size,
                    )
                    logger.info(f"Selected landmark: {candidate}")
                    return candidate, image
                except ExternalServiceValidationError:
                    logger.warning(f"画像取得失敗、次の候補を試行: {candidate.place_id}")
                    raise

        # reraise=True なのでここには到達しないが、型チェック用
        raise ExternalServiceValidationError(
            "画像を取得できませんでした",
            service_name="Street View API",
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
        # ランドマークの座標だと屋内の画像が取得される可能性があるため、近くの道路上の座標を取得する
        # NOTE: ただし道路の真下に地下道があると、地下道が出てしまうケースが多い
        target_coordinate = self._get_nearest_road_coordinate(coordinate)

        # 対象座標にストリートビューが存在するかを確認するためにメタデータを取得
        try:
            metadata = self.google_maps_gateway.get_street_view_metadata(target_coordinate)
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

    def _get_nearest_road_coordinate(self, coordinate: Coordinate) -> Coordinate:
        """座標の近くにある道路上の座標を取得する

        Args:
            coordinate: 対象座標

        Returns:
            Coordinate: 最寄りの道路上の座標、または元の座標 (道路が見つからない場合は元の座標)

        Raises:
            ExternalServiceError: Roads API呼び出しエラーが発生した場合
            ExternalServiceTimeoutError: Roads API呼び出しがタイムアウトした場合
        """
        try:
            snapped_coordinate = self.google_maps_gateway.snap_to_road(coordinate)
            if snapped_coordinate is not None:
                logger.info(
                    f"Using nearest road coordinate {snapped_coordinate} "
                    f"for Street View (original: {coordinate})"
                )
                return snapped_coordinate

            logger.info(
                f"No road found near {coordinate}, using original coordinate for Street View"
            )
            return coordinate
        except (ExternalServiceError, ExternalServiceTimeoutError) as e:
            logger.error(f"Roads API error while getting nearest road coordinate: {e}")
            raise
