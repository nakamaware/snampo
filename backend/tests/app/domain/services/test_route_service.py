"""route_serviceのテスト"""

import pytest

from app.domain.services.route_service import calculate_midpoint
from app.domain.value_objects import Coordinate


class TestCalculateMidpoint:
    """calculate_midpoint関数のテスト"""

    def test_奇数個の座標リストから中間地点を計算できること(self) -> None:
        """奇数個の座標リストから中間地点を計算できることを確認"""
        route_coordinates = [
            Coordinate(latitude=35.6812, longitude=139.7671),  # 東京駅
            Coordinate(latitude=35.6896, longitude=139.6917),  # 新宿駅
            Coordinate(latitude=35.6586, longitude=139.7014),  # 渋谷駅
        ]

        midpoint = calculate_midpoint(route_coordinates)

        # 中間地点は2番目の座標(インデックス1)であることを確認
        assert midpoint == route_coordinates[1]
        assert midpoint.latitude == 35.6896
        assert midpoint.longitude == 139.6917

    def test_偶数個の座標リストから中間地点を計算できること(self) -> None:
        """偶数個の座標リストから中間地点を計算できることを確認"""
        route_coordinates = [
            Coordinate(latitude=35.6812, longitude=139.7671),  # 東京駅
            Coordinate(latitude=35.6896, longitude=139.6917),  # 新宿駅
            Coordinate(latitude=35.6586, longitude=139.7014),  # 渋谷駅
            Coordinate(latitude=35.6762, longitude=139.6503),  # 品川駅
        ]

        midpoint = calculate_midpoint(route_coordinates)

        # 中間地点は3番目の座標(インデックス2)であることを確認
        assert midpoint == route_coordinates[2]
        assert midpoint.latitude == 35.6586
        assert midpoint.longitude == 139.7014

    def test_1つの座標のみの場合はその座標を返すこと(self) -> None:
        """1つの座標のみの場合はその座標を返すことを確認"""
        route_coordinates = [
            Coordinate(latitude=35.6812, longitude=139.7671),  # 東京駅
        ]

        midpoint = calculate_midpoint(route_coordinates)

        assert midpoint == route_coordinates[0]
        assert midpoint.latitude == 35.6812
        assert midpoint.longitude == 139.7671

    def test_2つの座標の場合は2番目の座標を返すこと(self) -> None:
        """2つの座標の場合は2番目の座標 (インデックス1) を返すことを確認"""
        route_coordinates = [
            Coordinate(latitude=35.6812, longitude=139.7671),  # 東京駅
            Coordinate(latitude=35.6896, longitude=139.6917),  # 新宿駅
        ]

        midpoint = calculate_midpoint(route_coordinates)

        # len // 2 = 2 // 2 = 1 なので、インデックス1 (2番目の座標) が返される
        assert midpoint == route_coordinates[1]
        assert midpoint.latitude == 35.6896
        assert midpoint.longitude == 139.6917

    def test_空のリストの場合はIndexErrorが発生すること(self) -> None:
        """空のリストの場合はIndexErrorが発生することを確認"""
        route_coordinates: list[Coordinate] = []

        with pytest.raises(IndexError):
            calculate_midpoint(route_coordinates)

    def test_戻り値がCoordinate型であること(self) -> None:
        """戻り値がCoordinate型であることを確認"""
        route_coordinates = [
            Coordinate(latitude=35.6812, longitude=139.7671),
            Coordinate(latitude=35.6896, longitude=139.6917),
            Coordinate(latitude=35.6586, longitude=139.7014),
        ]

        midpoint = calculate_midpoint(route_coordinates)

        assert isinstance(midpoint, Coordinate)

    def test_長いルートでも正しく中間地点を計算できること(self) -> None:
        """長いルートでも正しく中間地点を計算できることを確認"""
        route_coordinates = [
            Coordinate(latitude=35.0 + i * 0.01, longitude=139.0 + i * 0.01)
            for i in range(11)  # 11個の座標
        ]

        midpoint = calculate_midpoint(route_coordinates)

        # 11 // 2 = 5 なので、インデックス5の座標が返される
        expected_midpoint = route_coordinates[5]
        assert midpoint == expected_midpoint
