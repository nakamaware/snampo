"""Apple Maps Server API Gateway ポート (目的地ランドマーク検索)

Directions / Street View / Roads は GoogleMapsGateway のまま。
"""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Literal

from app.domain.value_objects import Coordinate, Landmark

AppleSearchSource = Literal["query", "fanout"]

# Apple PoiCategory (PascalCase) → フロントの genre_label が知る Google 系キー
APPLE_POI_CATEGORY_TO_GENRE: dict[str, str] = {
    "Airport": "airport",
    "AmusementPark": "amusement_park",
    "Aquarium": "aquarium",
    "Bakery": "bakery",
    "Bank": "bank",
    "Beach": "beach",
    "Brewery": "brewery",
    "Cafe": "cafe",
    "Campground": "campground",
    "Castle": "castle",
    "FoodMarket": "market",
    "GasStation": "gas_station",
    "Hiking": "hiking_area",
    "Hospital": "hospital",
    "Hotel": "resort_hotel",
    "Landmark": "landmark",
    "Library": "library",
    "Marina": "marina",
    "MovieTheater": "movie_theater",
    "Museum": "museum",
    "MusicVenue": "concert_hall",
    "NationalPark": "national_park",
    "Nightlife": "night_club",
    "Park": "park",
    "Parking": "parking",
    "Pharmacy": "pharmacy",
    "Planetarium": "planetarium",
    "Playground": "playground",
    "ReligiousSite": "religious_site",
    "Restaurant": "restaurant",
    "School": "school",
    "SkatePark": "skateboard_park",
    "Spa": "spa",
    "Stadium": "stadium",
    "Store": "store",
    "Theater": "performing_arts_theater",
    "University": "university",
    "Winery": "vineyard",
    "Zoo": "zoo",
}


def _pascal_to_snake(value: str) -> str:
    """PascalCase / camelCase を snake_case にする。"""
    chars: list[str] = []
    for index, char in enumerate(value):
        if char.isupper() and index > 0:
            chars.append("_")
        chars.append(char.lower())
    return "".join(chars)


def apple_poi_category_to_genre(poi_category: str | None) -> str | None:
    """Apple PoiCategory をフロント表示用ジャンルキーへ寄せる。

    既知カテゴリは Google Places 系の snake_case に固定する。
    未知の PascalCase は機械変換し、どちらでもなければそのまま返す。
    """
    if not poi_category:
        return None
    mapped = APPLE_POI_CATEGORY_TO_GENRE.get(poi_category)
    if mapped:
        return mapped
    if poi_category[:1].isupper() and "_" not in poi_category:
        return _pascal_to_snake(poi_category)
    return poi_category


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
