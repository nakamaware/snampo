"""ランドマーク計算ドメインサービス

ランドマーク検索に必要な座標計算などの純粋なビジネスロジックを提供します。
"""

import math
import random

from geopy.distance import geodesic

from app.domain.value_objects import Coordinate


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
    def generate_scattered_indices(n: int) -> list[int]:
        """全周に散らす順番のインデックスを生成 (開始位置はランダム)"""
        if n <= 1:
            return [0]

        indices = [0]
        step = n

        while step > 1:
            step //= 2
            new_indices = []
            for idx in indices:
                new_indices.append(idx)
                new_indices.append((idx + step) % n)
            indices = new_indices[:n]  # 重複を避ける

        # 開始位置をランダムにオフセット
        offset = random.randrange(n)  # noqa: S311 (ただのランダムの選択なので問題なし)
        return [(idx + offset) % n for idx in indices]

    scattered_indices = generate_scattered_indices(num_points)

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
