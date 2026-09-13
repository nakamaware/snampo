"""Google Places タイプ → Apple Maps PoiCategory の粗マッピング

スパイク用。1:1 対応ではないため、複数 Google タイプを同一 Apple カテゴリへ畳み込む。
Apple に無い語彙 (public_bath / japanese_inn / ferris_wheel 等) は Spa / Hotel / Landmark へ寄せる。

参考: https://developer.apple.com/documentation/applemapsserverapi/poicategory
"""

from __future__ import annotations

from app.config import LANDMARK_INCLUDED_TYPES

# Google Places primary type → Apple PoiCategory
# NOTE: public_bath→Spa, japanese_inn/cottage/resort_hotel→Hotel, ferris_wheel→Landmark は
# Apple 側に相当カテゴリが無いための粗畳み込み (想定どおりのギャップ)。
GOOGLE_TYPE_TO_APPLE_POI_CATEGORY: dict[str, str] = {
    # 自然・屋外
    "beach": "Beach",
    "national_park": "NationalPark",
    "state_park": "Park",
    "park": "Park",
    "city_park": "Park",
    "garden": "Park",
    "botanical_garden": "Park",
    "hiking_area": "Hiking",
    "picnic_ground": "Park",
    "plaza": "Landmark",
    "marina": "Marina",
    # 文化・ランドマーク
    "castle": "Castle",
    "art_museum": "Museum",
    "museum": "Museum",
    "history_museum": "Museum",
    "historical_landmark": "Landmark",
    "performing_arts_theater": "Theater",
    "concert_hall": "MusicVenue",
    "opera_house": "MusicVenue",
    "philharmonic_hall": "MusicVenue",
    "planetarium": "Planetarium",
    # エンタメ・映え
    "amusement_park": "AmusementPark",
    "aquarium": "Aquarium",
    "ferris_wheel": "Landmark",  # Apple に FerrisWheel 無し
    "observation_deck": "Landmark",
    "amphitheatre": "Theater",
    "cycling_park": "Park",
    "skateboard_park": "SkatePark",
    "dog_park": "Park",
    # 軽い立ち寄り
    "cafe": "Cafe",
    "coffee_shop": "Cafe",
    "coffee_stand": "Cafe",
    "bakery": "Bakery",
    "ice_cream_shop": "Cafe",
    "dessert_shop": "Bakery",
    "tea_house": "Cafe",
    # 発見系
    "book_store": "Store",
    "gift_shop": "Store",
    "market": "FoodMarket",
    "farmers_market": "FoodMarket",
    "flea_market": "Store",
    "shopping_mall": "Store",
    # チル
    "spa": "Spa",
    "sauna": "Spa",
    "public_bath": "Spa",  # Apple に PublicBath 無し
    # 非日常・雰囲気
    "campground": "Campground",
    "cottage": "Hotel",  # Apple に Cottage 無し
    "japanese_inn": "Hotel",  # Apple に JapaneseInn 無し
    "resort_hotel": "Hotel",
}

# Google リストに無いが snampo 向けに明示追加 (神社・寺院など)
EXTRA_APPLE_POI_CATEGORIES: tuple[str, ...] = ("ReligiousSite",)


def map_google_types_to_apple_poi_categories(
    google_types: list[str] | None = None,
    *,
    include_religious_site: bool = True,
) -> list[str]:
    """Google タイプ一覧をユニークな Apple PoiCategory リストへ変換する。

    Args:
        google_types: Google Places タイプ (None なら LANDMARK_INCLUDED_TYPES)
        include_religious_site: ReligiousSite を追加するか

    Returns:
        list[str]: 順序を保ったユニークな Apple PoiCategory
    """
    source = LANDMARK_INCLUDED_TYPES if google_types is None else google_types
    categories: list[str] = []
    seen: set[str] = set()

    for google_type in source:
        apple_category = GOOGLE_TYPE_TO_APPLE_POI_CATEGORY.get(google_type)
        if apple_category is None or apple_category in seen:
            continue
        seen.add(apple_category)
        categories.append(apple_category)

    if include_religious_site:
        for extra in EXTRA_APPLE_POI_CATEGORIES:
            if extra not in seen:
                seen.add(extra)
                categories.append(extra)

    return categories
