"""Apple Maps 目的地検索ポート。Directions / Street View / Roads は Google。"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Literal

from app.application.gateway_interfaces.apple_poi_genre import apple_poi_category_to_genre
from app.domain.value_objects import Coordinate, Landmark

AppleSearchSource = Literal["query", "fanout"]
APPLE_PLACE_ID_PREFIX = "apple:"


def prefix_apple_place_id(raw_id: str) -> str:
    """Apple place id に衝突回避プレフィックスを付ける。"""
    if raw_id.startswith(APPLE_PLACE_ID_PREFIX):
        return raw_id
    return f"{APPLE_PLACE_ID_PREFIX}{raw_id}"


def is_apple_place_id(place_id: str) -> bool:
    """Google Maps の query_place_id に載せられない `apple:` 付き ID かどうか。"""
    return place_id.startswith(APPLE_PLACE_ID_PREFIX)


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
        genre = apple_poi_category_to_genre(self.poi_category)
        types = [genre] if genre else None
        return Landmark(
            place_id=self.place_id,
            display_name=self.display_name,
            coordinate=self.coordinate,
            primary_type=genre,
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
