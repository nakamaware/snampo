"""ポリラインマッパー

Google Maps APIのポリライン形式をドメインオブジェクトに変換します。
"""

from app.domain.value_objects import Coordinate


def decode_polyline(polyline_str: str) -> list[Coordinate]:
    """Google Maps APIのポリラインをデコードして座標リストを生成

    Args:
        polyline_str: ポリラインの文字列

    Returns:
        list[Coordinate]: 座標リスト
    """
    index = 0
    coordinates = []
    lat = 0
    lng = 0

    while index < len(polyline_str):
        shift = 0
        result = 0
        while True:
            byte = ord(polyline_str[index]) - 63
            index += 1
            result |= (byte & 0x1F) << shift
            shift += 5
            if byte < 0x20:
                break

        dlat = ~(result >> 1) if result & 1 else (result >> 1)
        lat += dlat

        shift = 0
        result = 0
        while True:
            byte = ord(polyline_str[index]) - 63
            index += 1
            result |= (byte & 0x1F) << shift
            shift += 5
            if byte < 0x20:
                break

        dlng = ~(result >> 1) if result & 1 else (result >> 1)
        lng += dlng

        lat_float = lat * 1e-5
        lng_float = lng * 1e-5
        coordinates.append(Coordinate(latitude=lat_float, longitude=lng_float))

    return coordinates
