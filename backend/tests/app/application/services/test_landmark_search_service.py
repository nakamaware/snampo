"""LandmarkSearchService のテスト (Apple Gateway をモック)"""

from __future__ import annotations

from unittest.mock import MagicMock

from app.application.gateway_interfaces.apple_maps_gateway import AppleSearchHit
from app.application.services.landmark_search_service import LandmarkSearchService
from app.domain.exceptions import ExternalServiceError
from app.domain.value_objects import Coordinate


class TestLandmarkSearchService:
    """Apple 経由の目的地ランドマーク検索"""

    def test_ヒットをLandmarkに変換して返すこと(self) -> None:
        """Gateway のヒットが Landmark になる。"""
        center = Coordinate(latitude=35.232, longitude=139.107)
        hit_coord = Coordinate(latitude=35.240, longitude=139.110)
        gateway = MagicMock()
        gateway.search_landmarks_nearby.return_value = [
            AppleSearchHit(
                place_id="apple:1",
                display_name="箱根公園",
                coordinate=hit_coord,
                distance_m=2000.0,
                source="query",
                poi_category="Park",
            )
        ]
        service = LandmarkSearchService(gateway)

        landmarks = service.search_landmarks(
            center=center,
            target_distance_m=2000,
            target_count=5,
            max_calls=8,
        )

        assert len(landmarks) == 1
        assert landmarks[0].place_id == "apple:1"
        assert landmarks[0].display_name == "箱根公園"
        gateway.search_landmarks_nearby.assert_called_once_with(
            center,
            2000,
            target_count=5,
            max_calls=8,
        )

    def test_外部エラー時は空リストを返すこと(self) -> None:
        """Gateway 失敗でもルート生成側が続行できるよう空配列。"""
        gateway = MagicMock()
        gateway.search_landmarks_nearby.side_effect = ExternalServiceError(
            "boom", service_name="Apple Maps Server API"
        )
        service = LandmarkSearchService(gateway)
        center = Coordinate(latitude=35.0, longitude=139.0)

        assert (
            service.search_landmarks(
                center=center,
                target_distance_m=2000,
                target_count=5,
                max_calls=8,
            )
            == []
        )
