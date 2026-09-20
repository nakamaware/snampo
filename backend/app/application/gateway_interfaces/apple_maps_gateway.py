"""Apple Maps Server API の検索ポート。"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Literal

from app.application.gateway_interfaces.apple_poi_genre import apple_poi_category_to_genre
from app.domain.value_objects import Coordinate, Landmark

AppleSearchSource = Literal["query", "fanout"]
APPLE_PLACE_ID_PREFIX = "apple:"


def prefix_apple_place_id(raw_id: str) -> str:
    """Google Place ID と衝突しないよう `apple:` を付ける。"""
    if raw_id.startswith(APPLE_PLACE_ID_PREFIX):
        return raw_id
    return f"{APPLE_PLACE_ID_PREFIX}{raw_id}"


def is_apple_place_id(place_id: str) -> bool:
    """`apple:` 付きの Apple Maps ID かどうか。"""
    return place_id.startswith(APPLE_PLACE_ID_PREFIX)


@dataclass(frozen=True, slots=True)
class AppleSearchHit:
    """距離帯フィルタ後の Apple 検索 1 件。"""

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
    """層別日本語クエリと不足時ファンアウトで距離帯内 POI を返す。"""

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
        """距離帯内ヒットを返す。place_id は `apple:<id>` で dedup 済み。"""
        raise NotImplementedError
