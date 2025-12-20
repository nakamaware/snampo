"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

import math
import secrets

from app.domain.value_objects import Coordinate


def generate_random_point(center: Coordinate, radius_m: float) -> Coordinate:
    """指定された中心点から円周上のランダムな地点を生成

    Args:
        center: 中心点の座標
        radius_m: 半径 (メートル単位)

    Returns:
        Coordinate: 新しい座標
    """
    radius_in_degrees = radius_m / 111300

    # Use secrets module for cryptographically secure random number generation
    # Equivalent to random.uniform(0, 2 * math.pi) which is: 0 + (2*pi - 0) * random.random()
    # random.random() returns [0.0, 1.0), so we use secrets.randbelow(2**53) / (2**53) to match
    random_angle = (secrets.randbelow(2**53) / (2**53)) * 2 * math.pi

    # Calculate new coordinates
    center_lat_float = center.latitude.to_float()
    center_lng_float = center.longitude.to_float()
    new_lat_float = center_lat_float + (radius_in_degrees * math.cos(random_angle))
    new_lng_float = center_lng_float + (radius_in_degrees * math.sin(random_angle))

    return Coordinate(latitude=new_lat_float, longitude=new_lng_float)
