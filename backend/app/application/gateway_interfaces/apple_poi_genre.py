"""Apple PoiCategory をフロントのジャンルキーへ寄せる。"""

from __future__ import annotations

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
    chars: list[str] = []
    for index, char in enumerate(value):
        if char.isupper() and index > 0:
            chars.append("_")
        chars.append(char.lower())
    return "".join(chars)


def apple_poi_category_to_genre(poi_category: str | None) -> str | None:
    """既知カテゴリは Google 系 snake_case。未知の PascalCase は機械変換する。"""
    if not poi_category:
        return None
    mapped = APPLE_POI_CATEGORY_TO_GENRE.get(poi_category)
    if mapped:
        return mapped
    if poi_category[:1].isupper() and "_" not in poi_category:
        return _pascal_to_snake(poi_category)
    return poi_category
