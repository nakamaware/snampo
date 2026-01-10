"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

from geographiclib.geodesic import Geodesic
from geopy.distance import geodesic

from app.domain.value_objects import Coordinate


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
