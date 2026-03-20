"""mission_point_calculation_service のテスト"""

import pytest

from app.domain.services.mission_point_calculation_service import calculate_mission_point_count


@pytest.mark.parametrize(
    ("radius_m", "expected"),
    [
        (1, 2),
        (500, 2),
        (501, 4),
        (1000, 4),
        (1001, 6),
        (1500, 6),
        (1501, 8),
    ],
)
def test_calculate_mission_point_count_距離ごとの件数を返すこと(
    radius_m: int, expected: int
) -> None:
    """距離の閾値に応じて中間ミッション地点数が増えることを確認"""
    assert calculate_mission_point_count(radius_m) == expected


@pytest.mark.parametrize("radius_m", [0, -1])
def test_calculate_mission_point_count_半径が非正なら例外を送出すること(radius_m: int) -> None:
    """半径が0以下なら ValueError となることを確認"""
    with pytest.raises(ValueError, match="radius_m must be positive"):
        calculate_mission_point_count(radius_m)
