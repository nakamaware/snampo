"""coordinate_serviceのテスト"""

import pytest

from app.domain.services.coordinate_service import (
    calculate_bearing,
    calculate_distance,
    divide_route_into_segments,
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
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.7101, longitude=139.8107)

    points = divide_route_into_segments(start, end, 3)

    assert len(points) == 3
    assert all(isinstance(point, Coordinate) for point in points)


def test_divide_route_into_segments_中間地点が始点終点を含まないこと() -> None:
    """分割結果に始点終点そのものは含まれないことを確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.7101, longitude=139.8107)

    points = divide_route_into_segments(start, end, 2)

    assert all(point != start for point in points)
    assert all(point != end for point in points)


@pytest.mark.parametrize("num_segments", [0, -1])
def test_divide_route_into_segments_分割数が非正なら例外を送出すること(num_segments: int) -> None:
    """分割数が0以下なら ValueError となることを確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.7101, longitude=139.8107)

    with pytest.raises(ValueError, match="num_segments must be positive"):
        divide_route_into_segments(start, end, num_segments)


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
