"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

from itertools import pairwise

from geographiclib.geodesic import Geodesic
from geopy.distance import geodesic

from app.domain.value_objects import Coordinate


def calculate_distance(start: Coordinate, end: Coordinate) -> float:
    """2点間の測地線距離を計算

    地球表面上の最短経路(測地線)に沿った距離をメートル単位で返します。

    Args:
        start: 始点の座標
        end: 終点の座標

    Returns:
        float: 2点間の距離 (メートル単位)
    """
    start_point = (start.latitude, start.longitude)
    end_point = (end.latitude, end.longitude)

    distance = geodesic(start_point, end_point)
    return distance.meters


def calculate_bearing(start: Coordinate, end: Coordinate) -> float:
    """2点間の方位角 (bearing) を計算

    始点から終点への方位角を計算します。
    北が0度、東が90度、南が180度、西が270度の時計回りの角度を返します。

    Args:
        start: 始点の座標
        end: 終点の座標

    Returns:
        float: 方位角 (0-360度)
    """
    if start == end:
        return 0.0

    # geopyには方位角を直接取得するメソッドがないため、geographiclibを使用
    inverse_result = Geodesic.WGS84.Inverse(
        start.latitude, start.longitude, end.latitude, end.longitude
    )
    bearing = inverse_result["azi1"]

    # 負の値の場合は360度を加算して0-360度の範囲に正規化
    if bearing < 0:
        bearing += 360.0

    return bearing


def divide_route_into_segments(
    route_coordinates: list[Coordinate], num_segments: int
) -> list[Coordinate]:
    """ルート座標列から等間隔の中間地点を抽出する

    Directions API などで得たルート座標列に沿って、総距離を等分した位置にある
    中間地点を返します。始点・終点そのものは含みません。

    Args:
        route_coordinates: ルートを表す座標列
        num_segments: 取得したい中間地点の数

    Returns:
        中間地点のリスト(num_segments個以下)

    Raises:
        ValueError: num_segmentsが0以下の場合
    """
    if num_segments <= 0:
        raise ValueError("num_segments must be positive")

    if len(route_coordinates) < 2:
        return []

    segment_distances: list[float] = []
    total_distance = 0.0
    for start, end in pairwise(route_coordinates):
        distance = calculate_distance(start, end)
        segment_distances.append(distance)
        total_distance += distance

    if total_distance <= 0:
        return []

    target_distances = [total_distance * i / (num_segments + 1) for i in range(1, num_segments + 1)]
    intermediate_points: list[Coordinate] = []
    traversed_distance = 0.0
    segment_index = 0

    for target_distance in target_distances:
        while segment_index < len(segment_distances):
            segment_distance = segment_distances[segment_index]
            start = route_coordinates[segment_index]
            end = route_coordinates[segment_index + 1]

            if segment_distance <= 0:
                traversed_distance += segment_distance
                segment_index += 1
                continue

            if traversed_distance + segment_distance >= target_distance:
                distance_from_segment_start = target_distance - traversed_distance
                intermediate_points.append(
                    _interpolate_point_on_segment(start, end, distance_from_segment_start)
                )
                break

            traversed_distance += segment_distance
            segment_index += 1

    return intermediate_points


def _interpolate_point_on_segment(
    start: Coordinate, end: Coordinate, distance_from_start: float
) -> Coordinate:
    """2点を結ぶ測地線上の指定距離地点を返す"""
    if start == end or distance_from_start <= 0:
        return start

    inverse_result = Geodesic.WGS84.Inverse(
        start.latitude, start.longitude, end.latitude, end.longitude
    )
    bearing = inverse_result["azi1"]
    start_point = (start.latitude, start.longitude)
    point = geodesic(meters=distance_from_start).destination(start_point, bearing)
    return Coordinate(latitude=point.latitude, longitude=point.longitude)
