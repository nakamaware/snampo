"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

import random
from itertools import accumulate, pairwise

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


def calculate_route_length(route_coordinates: list[Coordinate]) -> float:
    """ルート座標列の総距離を計算

    Args:
        route_coordinates: ルートを表す座標列

    Returns:
        float: 総距離 (メートル単位)。座標が2点未満なら0
    """
    return sum(calculate_distance(start, end) for start, end in pairwise(route_coordinates))


def divide_route_into_segments(
    route_coordinates: list[Coordinate],
    num_segments: int,
    min_gap_ratio: float = 1.0,
    rng: random.Random | None = None,
) -> list[Coordinate]:
    """ルート座標列から中間地点を抽出する

    Directions API などで得たルート座標列を num_segments + 1 個の区間に分け、
    区間の境目にあたる中間地点を返します。始点・終点そのものは含みません。

    各区間の長さは「平均区間長 x min_gap_ratio」を最低保証し、残りの距離を
    ランダムに配分します。min_gap_ratio=1.0 のときは等間隔になります。

    Args:
        route_coordinates: ルートを表す座標列
        num_segments: 取得したい中間地点の数
        min_gap_ratio: 平均区間長に対する最低区間長の割合 (0以上1以下)
        rng: 乱数生成器 (Noneの場合は新しく生成)。テストではシード固定のものを渡す

    Returns:
        中間地点のリスト(num_segments個以下)

    Raises:
        ValueError: num_segmentsが0以下、またはmin_gap_ratioが範囲外の場合
    """
    if num_segments <= 0:
        raise ValueError("num_segments must be positive")
    if not 0.0 <= min_gap_ratio <= 1.0:
        raise ValueError("min_gap_ratio must be between 0 and 1")

    if len(route_coordinates) < 2:
        return []

    segment_distances = [
        calculate_distance(start, end) for start, end in pairwise(route_coordinates)
    ]
    total_distance = sum(segment_distances)

    if total_distance <= 0:
        return []

    gaps = generate_random_gaps(
        total_distance=total_distance,
        num_gaps=num_segments + 1,
        min_gap_ratio=min_gap_ratio,
        rng=rng or random.Random(),  # noqa: S311 - 配置のゆらぎ用で暗号用途ではない
    )
    target_distances = list(accumulate(gaps[:-1]))
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


def generate_random_gaps(
    total_distance: float,
    num_gaps: int,
    min_gap_ratio: float,
    rng: random.Random,
) -> list[float]:
    """総距離を、最低長を保証したランダムな長さの区間に分割する

    各区間に「平均区間長 x min_gap_ratio」を割り当て、残りの距離を
    一様ランダムな比率 (指数分布の正規化) で配分します。

    Args:
        total_distance: 総距離 (メートル単位)
        num_gaps: 区間数
        min_gap_ratio: 平均区間長に対する最低区間長の割合 (0以上1以下)
        rng: 乱数生成器

    Returns:
        区間長のリスト。合計は total_distance に一致する

    Raises:
        ValueError: num_gapsが0以下の場合
    """
    if num_gaps <= 0:
        raise ValueError("num_gaps must be positive")

    min_gap = total_distance / num_gaps * min_gap_ratio
    remaining_distance = total_distance - min_gap * num_gaps
    if remaining_distance <= 0:
        return [total_distance / num_gaps] * num_gaps

    weights = [rng.expovariate(1.0) for _ in range(num_gaps)]
    weight_sum = sum(weights)
    return [min_gap + remaining_distance * weight / weight_sum for weight in weights]


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
