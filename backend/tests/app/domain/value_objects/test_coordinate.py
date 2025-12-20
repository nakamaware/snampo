"""coordinateのテスト"""

import pytest

from app.domain.value_objects.coordinate import Coordinate
from app.domain.value_objects.latitude import Latitude
from app.domain.value_objects.longitude import Longitude


class TestCoordinate:
    """Coordinate値オブジェクトのテスト"""

    def test_float値で作成できること(self) -> None:
        """float値でCoordinateを作成できることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        assert coordinate.latitude.value == 35.6812
        assert coordinate.longitude.value == 139.7671

    def test_LatitudeとLongitude値オブジェクトで作成できること(self) -> None:
        """LatitudeとLongitude値オブジェクトでCoordinateを作成できることを確認"""
        latitude = Latitude(value=35.6812)
        longitude = Longitude(value=139.7671)

        coordinate = Coordinate(latitude=latitude, longitude=longitude)

        assert coordinate.latitude == latitude
        assert coordinate.longitude == longitude
        assert coordinate.latitude.value == 35.6812
        assert coordinate.longitude.value == 139.7671

    def test_floatとLatitudeの混合で作成できること(self) -> None:
        """floatとLatitude値オブジェクトの混合で作成できることを確認"""
        latitude = Latitude(value=35.6812)

        coordinate = Coordinate(latitude=latitude, longitude=139.7671)

        assert coordinate.latitude == latitude
        assert coordinate.longitude.value == 139.7671

    def test_Longitudeとfloatの混合で作成できること(self) -> None:
        """Longitude値オブジェクトとfloatの混合で作成できることを確認"""
        longitude = Longitude(value=139.7671)

        coordinate = Coordinate(latitude=35.6812, longitude=longitude)

        assert coordinate.latitude.value == 35.6812
        assert coordinate.longitude == longitude

    def test_to_tupleメソッドが正しく動作すること(self) -> None:
        """to_tupleメソッドが正しく動作することを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        result = coordinate.to_tuple()

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
        from pydantic import ValidationError

        with pytest.raises(ValidationError):
            coordinate.latitude = Latitude(value=36.0)  # type: ignore[misc]

    def test_無効な緯度値でValueErrorが発生すること(self) -> None:
        """無効な緯度値でValueErrorが発生することを確認"""
        with pytest.raises(ValueError, match="Latitude must be between -90 and 90"):
            Coordinate(latitude=90.1, longitude=139.7671)

    def test_無効な経度値でValueErrorが発生すること(self) -> None:
        """無効な経度値でValueErrorが発生することを確認"""
        with pytest.raises(ValueError, match="Longitude must be between -180 and 180"):
            Coordinate(latitude=35.6812, longitude=180.1)

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
            assert coordinate.latitude.value == lat
            assert coordinate.longitude.value == lng
            assert coordinate.to_tuple() == (lat, lng)

    def test_LatitudeとLongitude値オブジェクトで様々な値を作成できること(self) -> None:
        """LatitudeとLongitude値オブジェクトで様々な値を作成できることを確認"""
        latitude = Latitude(value=35.6812)
        longitude = Longitude(value=139.7671)

        coordinate = Coordinate(latitude=latitude, longitude=longitude)

        assert coordinate.latitude == latitude
        assert coordinate.longitude == longitude
        assert coordinate.to_tuple() == (35.6812, 139.7671)
