import logging

from injector import inject

from app.application.gateway_interfaces.apple_maps_gateway import AppleMapsGateway
from app.domain.exceptions import ExternalServiceError
from app.domain.value_objects import Coordinate, Landmark

logger = logging.getLogger(__name__)


class LandmarkSearchService:
    """目的地ランドマークを Apple Maps 経由で検索する。"""

    @inject
    def __init__(self, gateway: AppleMapsGateway) -> None:
        """初期化"""
        self._gateway = gateway

    def search_landmarks(
        self,
        center: Coordinate,
        target_distance_m: int,
        target_count: int,
        max_calls: int,
    ) -> list[Landmark]:
        """距離帯内のランドマークを返す。外部エラー時は空リスト。"""
        logger.debug(
            "Search landmarks via Apple Maps: center=%s distance=%s target=%s max_calls=%s",
            center,
            target_distance_m,
            target_count,
            max_calls,
        )
        try:
            hits = self._gateway.search_landmarks_nearby(
                center,
                target_distance_m,
                target_count=target_count,
                max_calls=max_calls,
            )
        except ExternalServiceError:
            logger.warning(
                "ランドマーク検索失敗: center=(%.4f, %.4f) distance=%s",
                float(center.latitude),
                float(center.longitude),
                target_distance_m,
                exc_info=True,
            )
            return []

        landmarks = [hit.to_landmark() for hit in hits]
        logger.debug("Find %s landmarks via Apple Maps", len(landmarks))
        return landmarks
