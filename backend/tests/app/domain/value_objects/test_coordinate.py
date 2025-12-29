"""coordinateのテスト"""

import pytest
from pydantic import ValidationError

from app.domain.value_objects.coordinate import Coordinate


class TestCoordinate:
    """Coordinate値オブジェクトのテスト"""

    def test_float値で作成できること(self) -> None:
        """float値でCoordinateを作成できることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        assert coordinate.latitude == 35.6812
        assert coordinate.longitude == 139.7671

    def test_to_float_tupleメソッドが正しく動作すること(self) -> None:
        """to_float_tupleメソッドが正しく動作することを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        result = coordinate.to_float_tuple()

        assert isinstance(result, tuple)
        assert len(result) == 2
        assert result[0] == 35.6812
        assert result[1] == 139.7671

    def test_hashメソッドが正しく動作すること(self) -> None:
        """__hash__メソッドが正しく動作することを確認"""
        coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
        coordinate2 = Coordinate(latitude=35.6812, longitude=139.7671)
        coordinate3 = Coordinate(latitude=35.6813, longitude=139.7671)

        # 同じ値の場合は同じハッシュ値を持つ
        assert hash(coordinate1) == hash(coordinate2)
        # 異なる値の場合は異なるハッシュ値を持つ(通常)
        assert hash(coordinate1) != hash(coordinate3)

    def test_同じ値のCoordinateが等しいこと(self) -> None:
        """同じ値のCoordinateが等しいことを確認"""
        coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
        coordinate2 = Coordinate(latitude=35.6812, longitude=139.7671)

        assert coordinate1 == coordinate2

    def test_異なる値のCoordinateが等しくないこと(self) -> None:
        """異なる値のCoordinateが等しくないことを確認"""
        coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
        coordinate2 = Coordinate(latitude=35.6813, longitude=139.7671)
        coordinate3 = Coordinate(latitude=35.6812, longitude=139.7672)

        assert coordinate1 != coordinate2
        assert coordinate1 != coordinate3

    def test_異なる型のオブジェクトと等しくないこと(self) -> None:
        """異なる型のオブジェクトと等しくないことを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        assert coordinate != "not a coordinate"
        assert coordinate != 123
        assert coordinate != (35.6812, 139.7671)

    def test_不変性が保証されていること(self) -> None:
        """frozen=Trueにより不変性が保証されていることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        # 属性の変更を試みるとエラーが発生する
        with pytest.raises((TypeError, ValueError)):
            coordinate.latitude = 36.0  # type: ignore[misc]

    def test_無効な緯度値でValueErrorが発生すること(self) -> None:
        """無効な緯度値でValidationErrorが発生することを確認"""
        with pytest.raises(ValidationError):
            Coordinate(latitude=90.1, longitude=139.7671)

    def test_無効な経度値でValueErrorが発生すること(self) -> None:
        """無効な経度値でValidationErrorが発生することを確認"""
        with pytest.raises(ValidationError):
            Coordinate(latitude=35.6812, longitude=180.1)

    def test_境界値の緯度で作成できること(self) -> None:
        """境界値の緯度でCoordinateを作成できることを確認"""
        coordinate1 = Coordinate(latitude=90.0, longitude=139.7671)
        coordinate2 = Coordinate(latitude=-90.0, longitude=139.7671)
        coordinate3 = Coordinate(latitude=0.0, longitude=139.7671)

        assert coordinate1.latitude == 90.0
        assert coordinate2.latitude == -90.0
        assert coordinate3.latitude == 0.0

    def test_境界値の経度で作成できること(self) -> None:
        """境界値の経度でCoordinateを作成できることを確認"""
        coordinate1 = Coordinate(latitude=35.6812, longitude=180.0)
        coordinate2 = Coordinate(latitude=35.6812, longitude=-180.0)
        coordinate3 = Coordinate(latitude=35.6812, longitude=0.0)

        assert coordinate1.longitude == 180.0
        assert coordinate2.longitude == -180.0
        assert coordinate3.longitude == 0.0

    def test_様々な有効な値で作成できること(self) -> None:
        """様々な有効な値でCoordinateを作成できることを確認"""
        test_cases = [
            (35.6812, 139.7671),  # 東京駅
            (0.0, 0.0),  # 赤道・本初子午線の交点
            (-90.0, -180.0),  # 南極・日付変更線
            (90.0, 180.0),  # 北極・日付変更線
            (35.6586, 139.7014),  # 渋谷駅
        ]

        for lat, lng in test_cases:
            coordinate = Coordinate(latitude=lat, longitude=lng)
            assert coordinate.latitude == lat
            assert coordinate.longitude == lng
            assert coordinate.to_float_tuple() == (lat, lng)
