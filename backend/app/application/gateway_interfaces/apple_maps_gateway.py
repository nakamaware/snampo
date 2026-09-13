"""Apple Maps Server API Gateway ポート (目的地ランドマーク検索)

Directions / Street View / Roads は GoogleMapsGateway のまま。
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Literal

from app.domain.value_objects import Coordinate, Landmark

AppleSearchSource = Literal["query", "fanout"]


@dataclass(frozen=True, slots=True)
class AppleSearchHit:
    """Apple 検索の 1 ヒット (距離帯フィルタ後)"""

    place_id: str
    display_name: str
    coordinate: Coordinate
    distance_m: float
    source: AppleSearchSource
    poi_category: str | None = None

    def to_landmark(self) -> Landmark:
        """既存 Landmark VO へ変換する。"""
        types = [self.poi_category] if self.poi_category else None
        return Landmark(
            place_id=self.place_id,
            display_name=self.display_name,
            coordinate=self.coordinate,
            primary_type=self.poi_category,
            types=types,
        )


class AppleMapsGateway(ABC):
    """Apple Maps Server API 検索ポート"""

    @abstractmethod
    def search_landmarks_nearby(
        self,
        coordinate: Coordinate,
        radius_m: int,
        *,
        target_count: int | None = None,
        distance_tolerance_percent: float | None = None,
        max_calls: int | None = None,
    ) -> list[AppleSearchHit]:
        """層別クエリ + ファンアウトで距離帯内のランドマークを検索する。

        Args:
            coordinate: 検索中心 (目的地リングの中心 = 現在地)
            radius_m: 目標距離 (メートル)。±tolerance% の距離帯でフィルタする。
            target_count: 目標件数 (未指定時は設定値)
            distance_tolerance_percent: 距離帯の許容 % (未指定時は設定値)
            max_calls: Apple /v1/search の最大呼び出し回数 (未指定時は設定値)

        Returns:
            list[AppleSearchHit]: place_id は `apple:<id>` 形式で dedup 済み
        """
        raise NotImplementedError
