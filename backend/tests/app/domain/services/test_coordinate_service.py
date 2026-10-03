"""coordinate_serviceのテスト"""

import random
from itertools import pairwise

import pytest

from app.domain.services.coordinate_service import (
    calculate_bearing,
    calculate_distance,
    calculate_route_length,
    divide_route_into_segments,
    generate_random_gaps,
)
from app.domain.value_objects import Coordinate


def test_calculate_distance_同じ座標の場合は0を返すこと() -> None:
    """同じ座標の場合は距離0を返すことを確認"""
    coordinate = Coordinate(latitude=35.6870958, longitude=139.8133963)

    distance = calculate_distance(coordinate, coordinate)

    assert abs(distance) < 0.01


def test_calculate_distance_東京駅から皇居までの距離が正しいこと() -> None:
    """東京駅から皇居までの距離が正しいことを確認"""
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    coordinate2 = Coordinate(latitude=35.6850, longitude=139.7528)

    distance = calculate_distance(coordinate1, coordinate2)

    assert 1200 < distance < 1500, f"距離が期待範囲外です: {distance}m"


def test_calculate_distance_順序を入れ替えても同じ距離になること() -> None:
    """座標の順序を入れ替えても同じ距離になることを確認"""
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    coordinate2 = Coordinate(latitude=35.6850, longitude=139.7528)

    assert calculate_distance(coordinate1, coordinate2) == calculate_distance(
        coordinate2, coordinate1
    )


def test_divide_route_into_segments_指定数だけ中間地点を返すこと() -> None:
    """ルート分割で要求した数の中間地点が返ることを確認"""
    route_coordinates = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.6900, longitude=139.7800),
        Coordinate(latitude=35.7101, longitude=139.8107),
    ]

    points = divide_route_into_segments(route_coordinates, 3)

    assert len(points) == 3
    assert all(isinstance(point, Coordinate) for point in points)


def test_divide_route_into_segments_中間地点が始点終点を含まないこと() -> None:
    """分割結果に始点終点そのものは含まれないことを確認"""
    route_coordinates = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.6900, longitude=139.7800),
        Coordinate(latitude=35.7101, longitude=139.8107),
    ]

    points = divide_route_into_segments(route_coordinates, 2)

    assert all(point != route_coordinates[0] for point in points)
    assert all(point != route_coordinates[-1] for point in points)


def test_divide_route_into_segments_折れ線ルート上から中間地点を抽出すること() -> None:
    """始点終点の直線ではなくルート座標列に沿って地点を抽出することを確認"""
    route_coordinates = [
        Coordinate(latitude=0.0, longitude=0.0),
        Coordinate(latitude=0.0, longitude=0.1),
        Coordinate(latitude=1.0, longitude=0.1),
    ]

    points = divide_route_into_segments(route_coordinates, 1)

    assert len(points) == 1
    assert points[0].longitude == pytest.approx(0.1, abs=1e-3)
    assert 0.0 < points[0].latitude < 1.0


def test_divide_route_into_segments_同一座標だけのルートでは空配列を返すこと() -> None:
    """総距離0のルートでは無効な waypoint を生成しないことを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    route_coordinates = [coordinate, coordinate, coordinate]

    points = divide_route_into_segments(route_coordinates, 2)

    assert points == []


@pytest.mark.parametrize("num_segments", [0, -1])
def test_divide_route_into_segments_分割数が非正なら例外を送出すること(num_segments: int) -> None:
    """分割数が0以下なら ValueError となることを確認"""
    route_coordinates = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.7101, longitude=139.8107),
    ]

    with pytest.raises(ValueError, match="num_segments must be positive"):
        divide_route_into_segments(route_coordinates, num_segments)


@pytest.mark.parametrize("min_gap_ratio", [-0.1, 1.1])
def test_divide_route_into_segments_最低間隔の割合が範囲外なら例外を送出すること(
    min_gap_ratio: float,
) -> None:
    """min_gap_ratio が0〜1の範囲外なら ValueError となることを確認"""
    route_coordinates = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.7101, longitude=139.8107),
    ]

    with pytest.raises(ValueError, match="min_gap_ratio must be between 0 and 1"):
        divide_route_into_segments(route_coordinates, 2, min_gap_ratio=min_gap_ratio)


# 経線に沿った直線ルート (約11.1km)。直線距離とルート沿いの距離が一致する
STRAIGHT_ROUTE = [
    Coordinate(latitude=0.0, longitude=0.0),
    Coordinate(latitude=0.05, longitude=0.0),
    Coordinate(latitude=0.1, longitude=0.0),
]


@pytest.mark.parametrize("seed", range(20))
def test_divide_route_into_segments_ランダム配置でも最低間隔を守ること(seed: int) -> None:
    """出発地・中間地点・目的地の隣り合う間隔がすべて最低間隔以上になることを確認"""
    num_segments = 6
    min_gap_ratio = 0.5
    route_length = calculate_route_length(STRAIGHT_ROUTE)
    min_gap = route_length / (num_segments + 1) * min_gap_ratio

    points = divide_route_into_segments(
        STRAIGHT_ROUTE,
        num_segments,
        min_gap_ratio=min_gap_ratio,
        rng=random.Random(seed),
    )

    assert len(points) == num_segments
    stops = [STRAIGHT_ROUTE[0], *points, STRAIGHT_ROUTE[-1]]
    for start, end in pairwise(stops):
        assert calculate_distance(start, end) >= min_gap - 1e-6


def test_divide_route_into_segments_同じシードなら同じ配置になること() -> None:
    """シードを固定すれば同じ中間地点が得られることを確認"""
    first = divide_route_into_segments(STRAIGHT_ROUTE, 4, min_gap_ratio=0.5, rng=random.Random(77))
    second = divide_route_into_segments(STRAIGHT_ROUTE, 4, min_gap_ratio=0.5, rng=random.Random(77))

    assert first == second


def test_divide_route_into_segments_ランダム配置では等間隔にならないこと() -> None:
    """min_gap_ratio < 1 なら等間隔の配置から外れることを確認"""
    even = divide_route_into_segments(STRAIGHT_ROUTE, 4)
    spread = divide_route_into_segments(STRAIGHT_ROUTE, 4, min_gap_ratio=0.5, rng=random.Random(77))

    assert len(spread) == len(even)
    assert spread != even


# ===== generate_random_gaps のテスト =====


@pytest.mark.parametrize("seed", range(20))
def test_generate_random_gaps_合計が総距離に一致し最低長を守ること(seed: int) -> None:
    """区間長の合計が総距離に一致し、どの区間も最低長以上であることを確認"""
    gaps = generate_random_gaps(
        total_distance=1800.0, num_gaps=7, min_gap_ratio=0.5, rng=random.Random(seed)
    )

    assert len(gaps) == 7
    assert sum(gaps) == pytest.approx(1800.0)
    assert min(gaps) >= 1800.0 / 7 * 0.5 - 1e-9


def test_generate_random_gaps_割合が1なら等間隔になること() -> None:
    """min_gap_ratio=1.0 では乱数によらず等間隔になることを確認"""
    gaps = generate_random_gaps(
        total_distance=900.0, num_gaps=3, min_gap_ratio=1.0, rng=random.Random(0)
    )

    assert gaps == pytest.approx([300.0, 300.0, 300.0])


@pytest.mark.parametrize("num_gaps", [0, -1])
def test_generate_random_gaps_区間数が非正なら例外を送出すること(num_gaps: int) -> None:
    """区間数が0以下なら ValueError となることを確認"""
    with pytest.raises(ValueError, match="num_gaps must be positive"):
        generate_random_gaps(
            total_distance=900.0, num_gaps=num_gaps, min_gap_ratio=0.5, rng=random.Random(0)
        )


# ===== calculate_route_length のテスト =====


def test_calculate_route_length_各区間の距離の合計を返すこと() -> None:
    """ルート長が隣り合う座標間の距離の合計になることを確認"""
    expected = calculate_distance(STRAIGHT_ROUTE[0], STRAIGHT_ROUTE[1]) + calculate_distance(
        STRAIGHT_ROUTE[1], STRAIGHT_ROUTE[2]
    )

    assert calculate_route_length(STRAIGHT_ROUTE) == pytest.approx(expected)


def test_calculate_route_length_座標が1点以下なら0を返すこと() -> None:
    """座標が足りない場合は0を返すことを確認"""
    assert calculate_route_length([STRAIGHT_ROUTE[0]]) == 0
    assert calculate_route_length([]) == 0


# ===== calculate_bearing のテスト =====


def test_calculate_bearing_北方向の方位角が0度に近いこと() -> None:
    """北方向の方位角が0度に近いことを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 東京駅の北側
    end = Coordinate(latitude=35.6912, longitude=139.7671)

    bearing = calculate_bearing(start, end)

    # 北方向なので0度に近い (許容誤差: 5度)
    assert 0 <= bearing < 5 or 355 < bearing <= 360, f"方位角が期待範囲外です: {bearing}度"


def test_calculate_bearing_東方向の方位角が90度に近いこと() -> None:
    """東方向の方位角が90度に近いことを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 東京駅の東側
    end = Coordinate(latitude=35.6812, longitude=139.7771)

    bearing = calculate_bearing(start, end)

    # 東方向なので90度に近い (許容誤差: 5度)
    assert 85 < bearing < 95, f"方位角が期待範囲外です: {bearing}度"


def test_calculate_bearing_南方向の方位角が180度に近いこと() -> None:
    """南方向の方位角が180度に近いことを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 東京駅の南側
    end = Coordinate(latitude=35.6712, longitude=139.7671)

    bearing = calculate_bearing(start, end)

    # 南方向なので180度に近い (許容誤差: 5度)
    assert 175 < bearing < 185, f"方位角が期待範囲外です: {bearing}度"


def test_calculate_bearing_西方向の方位角が270度に近いこと() -> None:
    """西方向の方位角が270度に近いことを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 東京駅の西側
    end = Coordinate(latitude=35.6812, longitude=139.7571)

    bearing = calculate_bearing(start, end)

    # 西方向なので270度に近い (許容誤差: 5度)
    assert 265 < bearing < 275, f"方位角が期待範囲外です: {bearing}度"


def test_calculate_bearing_同じ座標の場合は0度を返すこと() -> None:
    """同じ座標の場合は0度を返すことを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    bearing = calculate_bearing(coordinate, coordinate)

    # 同じ座標なので0度 (または360度)
    assert bearing == 0.0 or bearing == 360.0, f"方位角が期待値外です: {bearing}度"


def test_calculate_bearing_方位角が0から360度の範囲内であること() -> None:
    """方位角が0から360度の範囲内であることを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 新宿駅
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    bearing = calculate_bearing(start, end)

    # 0-360度の範囲内であることを確認
    assert 0 <= bearing <= 360, f"方位角が範囲外です: {bearing}度"


def test_calculate_bearing_負の値が正規化されること() -> None:
    """負の値が0-360度の範囲に正規化されることを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 東京駅の西側
    end = Coordinate(latitude=35.6812, longitude=139.7571)

    bearing = calculate_bearing(start, end)

    # 0-360度の範囲内であることを確認
    assert 0 <= bearing <= 360, f"方位角が範囲外です: {bearing}度"


def test_calculate_bearing_順序を入れ替えると逆方向になること() -> None:
    """座標の順序を入れ替えると逆方向になることを確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    bearing1 = calculate_bearing(start, end)
    bearing2 = calculate_bearing(end, start)

    # 逆方向なので180度の差がある (許容誤差: 10度)
    diff = abs(bearing1 - bearing2)
    assert 170 < diff < 190 or diff < 10, (
        f"方位角の差が期待範囲外です: bearing1={bearing1}度, bearing2={bearing2}度, diff={diff}度"
    )
