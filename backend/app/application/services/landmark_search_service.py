"""ランドマーク検索アプリケーションサービス

目的地選定向けのランドマーク検索オーケストレーションを提供します。
Apple Maps Server API の層別クエリ + ファンアウトを利用します。
(中間地点検索・Directions・Street View は GoogleMapsGateway のまま)
"""

import logging

from injector import inject

from app.application.gateway_interfaces.apple_maps_gateway import AppleMapsGateway
from app.domain.exceptions import ExternalServiceError
from app.domain.value_objects import Coordinate, Landmark

logger = logging.getLogger(__name__)


class LandmarkSearchService:
    """ランドマーク検索サービス

    Apple Maps のクエリバッグ検索で、目標距離帯上のランドマークを集めます。
    """

    @inject
    def __init__(self, gateway: AppleMapsGateway) -> None:
        """初期化

        Args:
            gateway: AppleMapsGateway のインスタンス
        """
        self._gateway = gateway

    def search_landmarks(
        self,
        center: Coordinate,
        target_distance_m: int,
        target_count: int,
        max_calls: int,
    ) -> list[Landmark]:
        """ランドマーク検索

        Apple /v1/search で層別日本語クエリ → 不足時円周ファンアウトを行い、
        目標距離 ±tolerance% 帯のユニーク件数を集める。

        Args:
            center: 中心座標
            target_distance_m: 指定距離 (メートル)。距離帯フィルタリングに使用。
            target_count: 目標件数
            max_calls: 最大 API 呼び出し回数

        Returns:
            ランドマークのリスト (重複排除済み、距離フィルタリング適用済み)
        """
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
