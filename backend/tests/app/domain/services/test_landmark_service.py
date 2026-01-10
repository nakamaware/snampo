"""landmark_serviceのテスト"""

import math

import pytest

from app.domain.services.landmark_service import (
    _generate_scattered_indices,
    calculate_distance,
    generate_equidistant_circle_points,
)
from app.domain.value_objects import Coordinate

# テストで使用する共通の座標
DEFAULT_LATITUDE = 35.6870958
DEFAULT_LONGITUDE = 139.8133963


def test_calculate_distance_同じ座標の場合は0を返すこと() -> None:
    """同じ座標の場合は距離0を返すことを確認"""
    coordinate = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)

    distance = calculate_distance(coordinate, coordinate)

    assert abs(distance) < 0.01  # ほぼ0であることを確認


def test_calculate_distance_東京駅から皇居までの距離が正しいこと() -> None:
    """東京駅から皇居までの距離が正しいことを確認"""
    # 東京駅
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    # 皇居
    coordinate2 = Coordinate(latitude=35.6850, longitude=139.7528)

    distance = calculate_distance(coordinate1, coordinate2)

    # 実際の距離は約1.3km
    assert 1200 < distance < 1500, f"距離が期待範囲外です: {distance}m"


def test_calculate_distance_順序を入れ替えても同じ距離になること() -> None:
    """座標の順序を入れ替えても同じ距離になることを確認"""
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    coordinate2 = Coordinate(latitude=35.6850, longitude=139.7528)

    distance1 = calculate_distance(coordinate1, coordinate2)
    distance2 = calculate_distance(coordinate2, coordinate1)

    assert distance1 == distance2


def test_generate_equidistant_circle_points_点の数が正しいこと() -> None:
    """円周上の点の数が正しいことを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    target_distance = 1000  # 1km
    search_radius = 100.0  # 100m

    points = generate_equidistant_circle_points(center, target_distance, search_radius)

    # 点数は自動計算されるが、少なくとも6点以上あるはず
    assert len(points) >= 6, f"点の数が少なすぎます: {len(points)}点"


def test_generate_equidistant_circle_points_すべての点が円周上にあること() -> None:
    """生成されたすべての点が円周上にあることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    target_distance = 1000  # 1km
    search_radius = 100.0  # 100m

    points = generate_equidistant_circle_points(center, target_distance, search_radius)

    tolerance_m = 10.0  # 10mの許容誤差
    for point_lat, point_lng in points:
        point_coordinate = Coordinate(latitude=point_lat, longitude=point_lng)
        distance = calculate_distance(center, point_coordinate)
        assert abs(distance - target_distance) <= tolerance_m, (
            f"点が円周上にありません: "
            f"期待距離={target_distance}m, 実際の距離={distance}m, "
            f"誤差={abs(distance - target_distance)}m"
        )


def test_generate_equidistant_circle_points_全周に散らされていること() -> None:
    """生成された点が全周に散らされていることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    target_distance = 1000  # 1km
    search_radius = 100.0  # 100m

    points = generate_equidistant_circle_points(center, target_distance, search_radius)

    # 角度を計算して、全周に分布していることを確認
    angles = []
    for point_lat, point_lng in points:
        delta_lat = point_lat - center.latitude
        delta_lng = point_lng - center.longitude
        angle = math.atan2(delta_lng, delta_lat)
        angles.append(angle)

    # 角度が0から2πの範囲に分布していることを確認
    # 4つの象限すべてに点が存在することを確認
    quadrants = [0, 0, 0, 0]  # 4象限のカウント
    for angle in angles:
        normalized_angle = (angle + 2 * math.pi) % (2 * math.pi)
        quadrant = int(normalized_angle / (math.pi / 2))
        quadrants[quadrant] += 1

    # すべての象限に少なくとも1つの点が存在することを確認
    assert all(count > 0 for count in quadrants), "全周に点が散らされていません"


# --- generate_scattered_indices のテスト ---


def test_generate_scattered_indices_n1の場合は0のみを返すこと() -> None:
    """n=1の場合は [0] を返すことを確認"""
    result = _generate_scattered_indices(1)

    assert result == [0]


def test_generate_scattered_indices_n0の場合は0のみを返すこと() -> None:
    """n=0の場合は [0] を返すことを確認"""
    result = _generate_scattered_indices(0)

    assert result == [0]


@pytest.mark.parametrize(
    "n",
    [
        2,  # 最小の有効値
        3,  # 素数
        6,  # 2*3
        7,  # 素数
        8,  # 2のべき乗
        9,  # 3^2
        10,  # 2*5
        12,  # 2^2*3
        15,  # 3*5
        16,  # 2のべき乗
        63,  # 7*9 (2のべき乗でない大きな値)
        64,  # 2のべき乗
        100,  # 2^2*5^2
    ],
)
def test_generate_scattered_indices_全てのインデックスが1回ずつ生成されること(n: int) -> None:
    """生成されたインデックスが 0..n-1 を全て1回ずつ含むことを確認"""
    result = _generate_scattered_indices(n)

    # 長さが正しいこと
    assert len(result) == n, f"長さが不正です: 期待={n}, 実際={len(result)}"

    # 全てのインデックスが含まれていること (重複なし)
    assert set(result) == set(range(n)), (
        f"インデックスが不正です: 期待={set(range(n))}, 実際={set(result)}"
    )


def test_generate_scattered_indices_複数回呼び出しで異なる結果を返すこと() -> None:
    """ランダム性により、複数回呼び出すと異なる結果を返すことを確認"""
    n = 20
    results = [tuple(_generate_scattered_indices(n)) for _ in range(10)]

    # 少なくとも2つ以上の異なる結果があることを確認
    unique_results = set(results)
    assert len(unique_results) >= 2, "ランダム性がありません (すべて同じ結果)"


def test_generate_scattered_indices_結果が常にリストであること() -> None:
    """戻り値が常にリスト型であることを確認"""
    for n in [0, 1, 5, 10]:
        result = _generate_scattered_indices(n)
        assert isinstance(result, list), f"戻り値がリストではありません: {type(result)}"
