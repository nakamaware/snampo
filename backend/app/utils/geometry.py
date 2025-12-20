"""座標計算とポリラインデコードのユーティリティ関数"""

import math
import secrets

from app.value_objects import Latitude, Longitude


def generate_random_point(
    center_lat: Latitude, center_lng: Longitude, radius_m: float
) -> tuple[Latitude, Longitude]:
    """指定された中心点から半径内のランダムな地点を生成

    Args:
        center_lat: 中心点の緯度
        center_lng: 中心点の経度
        radius_m: 半径 (メートル単位)

    Returns:
        new_lat: 新しい緯度
        new_lng: 新しい経度
    """
    radius_in_degrees = radius_m / 111300

    # Use secrets module for cryptographically secure random number generation
    # Equivalent to random.uniform(0, 2 * math.pi) which is: 0 + (2*pi - 0) * random.random()
    # random.random() returns [0.0, 1.0), so we use secrets.randbelow(2**53) / (2**53) to match
    random_angle = (secrets.randbelow(2**53) / (2**53)) * 2 * math.pi

    # Calculate new coordinates
    center_lat_float = center_lat.to_float()
    center_lng_float = center_lng.to_float()
    new_lat_float = center_lat_float + (radius_in_degrees * math.cos(random_angle))
    new_lng_float = center_lng_float + (radius_in_degrees * math.sin(random_angle))

    return Latitude(value=new_lat_float), Longitude(value=new_lng_float)


def decode_polyline(polyline_str: str) -> list[tuple[Latitude, Longitude]]:
    """ポリラインをデコードして座標リストを生成

    Args:
        polyline_str: ポリラインの文字列

    Returns:
        coordinates: 座標リスト
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
        coordinates.append((Latitude(value=lat_float), Longitude(value=lng_float)))

    return coordinates
