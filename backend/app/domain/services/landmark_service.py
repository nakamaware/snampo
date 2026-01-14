"""ランドマーク計算ドメインサービス

ランドマーク検索に必要な座標計算などの純粋なビジネスロジックを提供します。
"""

import math
import random

from geopy.distance import geodesic

from app.domain.value_objects import Coordinate


def calculate_search_radius(
    target_distance_m: int,
    tolerance: float,
    min_search_radius: int,
) -> int:
    """検索半径を計算

    Args:
        target_distance_m: 目標距離 (メートル)
        tolerance: 許容誤差 (0-1の範囲)
        min_search_radius: 最小検索半径 (メートル)

    Returns:
        検索半径 (メートル)
    """
    return max(min_search_radius, int(target_distance_m * tolerance))


def generate_equidistant_circle_points(
    center: Coordinate,
    target_distance: int,
    search_radius: float,
) -> list[tuple[float, float]]:
    """指定距離の円周上に等間隔で点を生成 (全周に散らす順番)

    Args:
        center: 中心座標
        target_distance: 指定距離 (メートル)
        search_radius: 各点での検索半径 (メートル)

    Returns:
        円周上の点のリスト [(lat, lng), ...] (全周に散らす順番)
    """
    # 点数を自動計算
    num_points = max(6, math.ceil(2 * math.pi * target_distance / search_radius))

    # 全周に散らす順番のインデックスを生成
    # 例: 8点の場合 → [0, 4, 2, 6, 1, 5, 3, 7]
    # これにより、最初の数回で全周をカバーできる
    # 開始位置はランダムにオフセットされる
    scattered_indices = _generate_scattered_indices(num_points)

    points: list[tuple[float, float]] = []
    origin = (center.latitude, center.longitude)

    # 散らした順番で点を生成
    for idx in scattered_indices:
        # 方位角を計算 (北が0度、東が90度)
        bearing = 360.0 * idx / num_points

        # geopyで指定距離・方位角の地点を計算 (WGS-84楕円体モデル)
        destination = geodesic(meters=target_distance).destination(origin, bearing=bearing)
        points.append((destination.latitude, destination.longitude))

    return points


def _generate_scattered_indices(n: int) -> list[int]:
    """全周に散らす順番のインデックスを生成 (開始位置はランダム)

    n と互いに素な step を使った full-cycle generation により、
    全てのインデックス 0..n-1 を正確に1回ずつ生成します。

    Args:
        n: 生成するインデックスの総数

    Returns:
        0..n-1 のインデックスを全周に散らした順番で返すリスト
    """
    if n <= 1:
        return [0]

    # ランダムな開始オフセットを選択
    offset = random.randrange(n)  # noqa: S311 (ただのランダムの選択なので問題なし)

    # n と互いに素な step を 1..n-1 からランダムに選択
    # gcd(step, n) == 1 なら step は n と互いに素
    while True:
        step = random.randrange(1, n)  # noqa: S311 (ただのランダムの選択なので問題なし)
        if math.gcd(step, n) == 1:
            break

    return [(offset + i * step) % n for i in range(n)]


def calculate_distance(coordinate1: Coordinate, coordinate2: Coordinate) -> float:
    """2点間の距離を計算 (WGS-84楕円体モデル)

    geopy の geodesic を使用して高精度な距離計算を行います。

    Args:
        coordinate1: 地点1の座標
        coordinate2: 地点2の座標

    Returns:
        距離 (メートル)
    """
    point1 = (coordinate1.latitude, coordinate1.longitude)
    point2 = (coordinate2.latitude, coordinate2.longitude)
    return geodesic(point1, point2).meters
