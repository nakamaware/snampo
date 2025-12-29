"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

import math
import secrets

from app.domain.value_objects import Coordinate

# 緯度1度あたりのメートル数の近似値 (地球の平均半径に基づく)
# 実際の値は緯度によってわずかに異なるが、小さい半径ではこの近似で十分
METERS_PER_DEGREE_LAT = 111300


def generate_random_point(center: Coordinate, radius_m: float) -> Coordinate:
    """指定された中心点から円周上のランダムな地点を生成

    この関数は簡易的な平面近似を使用しており、以下の制限があります:
    - 緯度1度あたりのメートル数を固定値として使用(実際は緯度によって異なる)
    - 経度の変換では緯度を考慮してcos(latitude)を適用
    - 小さい半径 (数km以下) では十分な精度が得られるが、大きな半径では誤差が大きくなる

    高精度が必要な場合は、球面三角法や測地線の公式 (例: Haversine公式、Vincenty公式)
    を使用することを推奨します。

    Args:
        center: 中心点の座標
        radius_m: 半径 (メートル単位)

    Returns:
        Coordinate: 新しい座標
    """
    center_lat_float = center.latitude
    center_lng_float = center.longitude
    center_lat_radians = math.radians(center_lat_float)

    # 緯度方向の半径(度単位)
    radius_lat_degrees = radius_m / METERS_PER_DEGREE_LAT
    # 経度方向の半径(度単位) - 緯度を考慮してcos(latitude)で調整
    radius_lng_degrees = radius_m / (METERS_PER_DEGREE_LAT * math.cos(center_lat_radians))

    # Use secrets module for cryptographically secure random number generation
    # Equivalent to random.uniform(0, 2 * math.pi) which is: 0 + (2*pi - 0) * random.random()
    # random.random() returns [0.0, 1.0), so we use secrets.randbelow(2**53) / (2**53) to match
    random_angle = (secrets.randbelow(2**53) / (2**53)) * 2 * math.pi

    # Calculate new coordinates
    new_lat_float = center_lat_float + (radius_lat_degrees * math.cos(random_angle))
    new_lng_float = center_lng_float + (radius_lng_degrees * math.sin(random_angle))

    return Coordinate(latitude=new_lat_float, longitude=new_lng_float)
