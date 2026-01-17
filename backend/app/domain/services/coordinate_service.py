"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

import secrets

from geopy.distance import geodesic

from app.domain.value_objects import Coordinate


def generate_random_point(center: Coordinate, radius_m: float) -> Coordinate:
    """指定された中心点から円周上のランダムな地点を生成

    geopyのgeodesicクラスを使用して、WGS84楕円体に基づく高精度な測地線計算を行います。
    これにより、任意の半径(数メートルから数千キロメートルまで)で正確な座標計算が可能です。

    Args:
        center: 中心点の座標
        radius_m: 半径 (メートル単位)

    Returns:
        Coordinate: 新しい座標
    """
    # secretsモジュールを使用して暗号学的に安全な乱数生成を行う
    # ランダムな方位角(0-360度)を生成
    # random.uniform(0, 360)と同等: 0 + (360 - 0) * random.random()
    # random.random()は[0.0, 1.0)を返すため、
    # secrets.randbelow(2**53) / (2**53)を使用して同じ挙動を実現
    random_bearing = (secrets.randbelow(2**53) / (2**53)) * 360.0

    # 測地線計算を使用して目的地の座標を計算
    center_point = (center.latitude, center.longitude)
    destination = geodesic(meters=radius_m).destination(center_point, bearing=random_bearing)

    return Coordinate(latitude=destination.latitude, longitude=destination.longitude)
