"""ランドマーク計算ドメインサービス

ランドマーク検索に必要な座標計算などの純粋なビジネスロジックを提供します。
"""

import math
import random

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

    # 散らした順番で点を生成
    for idx in scattered_indices:
        angle_rad = 2 * math.pi * idx / num_points

        # target_distance分だけ移動した点を計算
        d_lat = _meters_to_deg_lat(target_distance) * math.cos(angle_rad)
        d_lng = _meters_to_deg_lng(target_distance, center.latitude) * math.sin(angle_rad)

        point_lat = center.latitude + d_lat
        point_lng = center.longitude + d_lng
        points.append((point_lat, point_lng))

    return points


def calculate_distance(coordinate1: Coordinate, coordinate2: Coordinate) -> float:
    """2点間の距離を計算 (ハーバーサイン公式)

    Args:
        coordinate1: 地点1の座標
        coordinate2: 地点2の座標

    Returns:
        距離 (メートル)
    """
    # 地球の半径 (メートル)
    r = 6371000

    # 緯度・経度をラジアンに変換
    phi1 = math.radians(coordinate1.latitude)
    phi2 = math.radians(coordinate2.latitude)
    delta_phi = math.radians(coordinate2.latitude - coordinate1.latitude)
    delta_lambda = math.radians(coordinate2.longitude - coordinate1.longitude)

    # ハーバーサイン公式
    a = (
        math.sin(delta_phi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

    # 距離を計算
    return r * c


def _meters_to_deg_lat(meters: float) -> float:
    """メートルを緯度の度数に変換

    Args:
        meters: 距離 (メートル)

    Returns:
        緯度の度数
    """
    return meters / 111_320


def _meters_to_deg_lng(meters: float, at_lat_deg: float) -> float:
    """メートルを経度の度数に変換 (緯度による補正あり)

    Args:
        meters: 距離 (メートル)
        at_lat_deg: 基準緯度 (度数)

    Returns:
        経度の度数
    """
    return meters / (111_320 * math.cos(math.radians(at_lat_deg)))
