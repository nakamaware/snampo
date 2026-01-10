"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

import secrets

from geographiclib.geodesic import Geodesic
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


def calculate_geodesic_midpoint(start: Coordinate, end: Coordinate) -> Coordinate:
    """2点間の測地線上の中間地点を計算

    測地線(地球表面上の最短経路)に沿った中間地点を計算します。
    これにより、緯度・経度の単純な平均ではなく、
    実際の地球表面上での正確な中間地点が得られます。

    Args:
        start: 始点の座標
        end: 終点の座標

    Returns:
        Coordinate: 測地線上の中間地点の座標
    """
    start_point = (start.latitude, start.longitude)
    end_point = (end.latitude, end.longitude)

    # 2点間の測地線距離を計算
    total = geodesic(start_point, end_point)

    # 2点間の方位角を計算してから、始点から半分の距離で中間地点を計算
    # geopyには方位角を直接取得するメソッドがないため、geographiclibを使用
    inverse_result = Geodesic.WGS84.Inverse(
        start.latitude, start.longitude, end.latitude, end.longitude
    )
    bearing = inverse_result["azi1"]

    # 始点から半分の距離・同じ方位角で中間地点を計算
    midpoint = geodesic(meters=total.meters / 2).destination(start_point, bearing)

    return Coordinate(latitude=midpoint.latitude, longitude=midpoint.longitude)
