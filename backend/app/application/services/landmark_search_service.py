"""ランドマーク検索アプリケーションサービス

ランドマーク検索のオーケストレーションを提供します。
"""

import logging

from injector import inject

from app.application.gateway_interfaces.google_maps_gateway import GoogleMapsGateway
from app.config import (
    LANDMARK_DISTANCE_TOLERANCE_PERCENT,
    MIN_SEARCH_RADIUS_M,
)
from app.domain.services.landmark_service import (
    calculate_distance,
    calculate_search_radius,
    generate_equidistant_circle_points,
)
from app.domain.value_objects import Coordinate, Landmark

logger = logging.getLogger(__name__)


class LandmarkSearchService:
    """ランドマーク検索サービス

    段階的探索戦略を用いてランドマークを検索します。
    """

    @inject
    def __init__(self, gateway: GoogleMapsGateway) -> None:
        """初期化

        Args:
            gateway: GoogleMapsGatewayのインスタンス
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

        Nearby APIでは注目度順で最大20件までしか取得できないため、段階的に取得する

        1. まずは中心地から指定した距離内のランドマークを20件検索
        2. 円周上に等間隔の点を生成し、それぞれの点から指定した距離内のランドマークを20件検索
        3. 2つの検索結果を結合して、目標件数に達するまで繰り返す

        Args:
            center: 中心座標
            target_distance_m: 指定距離 (メートル)。検索半径および距離フィルタリングに使用。
                ±LANDMARK_DISTANCE_TOLERANCE_PERCENT%の範囲でフィルタリング
            target_count: 目標件数
            max_calls: 最大API呼び出し回数

        Returns:
            ランドマークのリスト (重複排除済み、距離フィルタリング適用済み)
        """
        # 距離フィルタリング用の範囲計算:
        # target_distance_m * (1 - tolerance) <= distance <= target_distance_m * (1 + tolerance)
        tolerance = LANDMARK_DISTANCE_TOLERANCE_PERCENT / 100.0
        min_filter_distance = target_distance_m * (1 - tolerance)
        max_filter_distance = target_distance_m * (1 + tolerance)

        seen: dict[str, Landmark] = {}  # Place IDをキーとした重複排除用マップ
        calls = 0

        # 1. 中心地から指定した距離内のランドマークを検索
        logger.info(f"Search landmarks around center: {center}")
        try:
            landmarks = self._gateway.search_landmarks_nearby(center, target_distance_m)
            calls += 1
            seen = self._add_landmarks(
                seen, landmarks, min_filter_distance, max_filter_distance, center
            )
            logger.info(f"Find {len(seen)} new landmarks around center")
            if self._should_stop(seen, target_count, calls, max_calls):
                return list(seen.values())
        except Exception:
            logger.warning(
                f"中心点 ({center.latitude:.4f}, {center.longitude:.4f}) でのランドマーク検索失敗",
                exc_info=True,
            )
            return []

        # 2. 円周上に等間隔の点を生成し、それぞれの点から指定した距離内のランドマークを検索
        search_radius = calculate_search_radius(target_distance_m, tolerance, MIN_SEARCH_RADIUS_M)
        circle_points = generate_equidistant_circle_points(center, target_distance_m, search_radius)

        # 円周上の点から指定した距離内のランドマークを検索
        logger.info(f"Search landmarks around circle points: {circle_points}")
        for point_lat, point_lng in circle_points:
            try:
                point_coordinate = Coordinate(latitude=point_lat, longitude=point_lng)
                landmarks = self._gateway.search_landmarks_nearby(point_coordinate, search_radius)
                calls += 1
                prev_seen_length = len(seen)
                seen = self._add_landmarks(
                    seen, landmarks, min_filter_distance, max_filter_distance, center
                )
                logger.info(
                    f"Find {len(seen) - prev_seen_length} new landmarks around circle points"
                )
                if self._should_stop(seen, target_count, calls, max_calls):
                    return list(seen.values())
            except Exception as e:
                # 個別の点でのエラーは無視して続行
                logger.warning(
                    f"円周上の点 ({point_lat:.4f}, {point_lng:.4f}) で検索失敗: {e}",
                    exc_info=True,
                )
                continue

        return list(seen.values())

    def _add_landmarks(
        self,
        seen: dict[str, Landmark],
        landmarks: list[Landmark],
        min_filter_distance: float,
        max_filter_distance: float,
        center: Coordinate,
    ) -> dict[str, Landmark]:
        """距離フィルタリング付きで結果を追加"""
        # 非破壊的メソッドにするためにcopyを使用
        new_seen: dict[str, Landmark] = seen.copy()

        for landmark in landmarks:
            place_id = landmark.place_id
            if place_id in new_seen:
                continue

            # 距離フィルタリング
            dist = calculate_distance(center, landmark.coordinate)
            if min_filter_distance <= dist <= max_filter_distance:
                new_seen[place_id] = landmark

        return new_seen

    def _should_stop(
        self,
        seen: dict[str, Landmark],
        target_count: int,
        calls: int,
        max_calls: int,
    ) -> bool:
        """停止条件をチェック

        目標件数に達したか、最大呼び出し回数に達したか

        Args:
            seen: 発見済みランドマークのマップ
            target_count: 目標件数
            calls: 呼び出し回数
            max_calls: 最大呼び出し回数

        Returns:
            停止条件を満たしているかどうか
        """
        reached_target_count = len(seen) >= target_count
        reached_max_calls = calls >= max_calls
        return reached_target_count or reached_max_calls
