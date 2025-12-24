"""coordinate, latitude, longitudeのテスト"""

import pytest

from app.domain.value_objects.coordinate import Coordinate, Latitude, Longitude


class TestLatitude:
    """Latitude値オブジェクトのテスト"""

    def test_正常な範囲内の値で作成できること(self) -> None:
        """正常な範囲内の値でLatitudeを作成できることを確認"""
        latitude = Latitude(value=35.6812)

        assert latitude.value == 35.6812
        assert latitude.to_float() == 35.6812

    def test_境界値の90で作成できること(self) -> None:
        """境界値の90でLatitudeを作成できることを確認"""
        latitude = Latitude(value=90.0)

        assert latitude.value == 90.0
        assert latitude.to_float() == 90.0

    def test_境界値のマイナス90で作成できること(self) -> None:
        """境界値の-90でLatitudeを作成できることを確認"""
        latitude = Latitude(value=-90.0)

        assert latitude.value == -90.0
        assert latitude.to_float() == -90.0

    def test_境界値の0で作成できること(self) -> None:
        """境界値の0でLatitudeを作成できることを確認"""
        latitude = Latitude(value=0.0)

        assert latitude.value == 0.0
        assert latitude.to_float() == 0.0

    def test_90より大きい値でValueErrorが発生すること(self) -> None:
        """90より大きい値でValueErrorが発生することを確認"""
        with pytest.raises(ValueError, match="Latitude must be between -90 and 90"):
            Latitude(value=90.1)

    def test_マイナス90より小さい値でValueErrorが発生すること(self) -> None:
        """-90より小さい値でValueErrorが発生することを確認"""
        with pytest.raises(ValueError, match="Latitude must be between -90 and 90"):
            Latitude(value=-90.1)

    def test_to_floatメソッドが正しく動作すること(self) -> None:
        """to_floatメソッドが正しく動作することを確認"""
        latitude = Latitude(value=35.6812)

        result = latitude.to_float()

        assert isinstance(result, float)
        assert result == 35.6812

    def test_hashメソッドが正しく動作すること(self) -> None:
        """__hash__メソッドが正しく動作することを確認"""
        latitude1 = Latitude(value=35.6812)
        latitude2 = Latitude(value=35.6812)
        latitude3 = Latitude(value=35.6813)

        # 同じ値の場合は同じハッシュ値を持つ
        assert hash(latitude1) == hash(latitude2)
        # 異なる値の場合は異なるハッシュ値を持つ(通常)
        assert hash(latitude1) != hash(latitude3)

    def test_不変性が保証されていること(self) -> None:
        """frozen=Trueにより不変性が保証されていることを確認"""
        latitude = Latitude(value=35.6812)

        # 属性の変更を試みるとエラーが発生する
        from dataclasses import FrozenInstanceError

        with pytest.raises(FrozenInstanceError):
            latitude.value = 36.0  # type: ignore[misc]

    def test_異なる値のLatitudeが等しくないこと(self) -> None:
        """異なる値のLatitudeが等しくないことを確認"""
        latitude1 = Latitude(value=35.6812)
        latitude2 = Latitude(value=35.6813)

        assert latitude1 != latitude2

    def test_同じ値のLatitudeが等しいこと(self) -> None:
        """同じ値のLatitudeが等しいことを確認"""
        latitude1 = Latitude(value=35.6812)
        latitude2 = Latitude(value=35.6812)

        assert latitude1 == latitude2

    def test_様々な有効な値で作成できること(self) -> None:
        """様々な有効な値でLatitudeを作成できることを確認"""
        test_values = [
            -90.0,
            -45.0,
            0.0,
            45.0,
            90.0,
            35.6812,
            -35.6812,
        ]

        for value in test_values:
            latitude = Latitude(value=value)
            assert latitude.value == value
            assert latitude.to_float() == value


class TestLongitude:
    """Longitude値オブジェクトのテスト"""

    def test_正常な範囲内の値で作成できること(self) -> None:
        """正常な範囲内の値でLongitudeを作成できることを確認"""
        longitude = Longitude(value=139.7671)

        assert longitude.value == 139.7671
        assert longitude.to_float() == 139.7671

    def test_境界値の180で作成できること(self) -> None:
        """境界値の180でLongitudeを作成できることを確認"""
        longitude = Longitude(value=180.0)

        assert longitude.value == 180.0
        assert longitude.to_float() == 180.0

    def test_境界値のマイナス180で作成できること(self) -> None:
        """境界値の-180でLongitudeを作成できることを確認"""
        longitude = Longitude(value=-180.0)

        assert longitude.value == -180.0
        assert longitude.to_float() == -180.0

    def test_境界値の0で作成できること(self) -> None:
        """境界値の0でLongitudeを作成できることを確認"""
        longitude = Longitude(value=0.0)

        assert longitude.value == 0.0
        assert longitude.to_float() == 0.0

    def test_180より大きい値でValueErrorが発生すること(self) -> None:
        """180より大きい値でValueErrorが発生することを確認"""
        with pytest.raises(ValueError, match="Longitude must be between -180 and 180"):
            Longitude(value=180.1)

    def test_マイナス180より小さい値でValueErrorが発生すること(self) -> None:
        """-180より小さい値でValueErrorが発生することを確認"""
        with pytest.raises(ValueError, match="Longitude must be between -180 and 180"):
            Longitude(value=-180.1)

    def test_to_floatメソッドが正しく動作すること(self) -> None:
        """to_floatメソッドが正しく動作することを確認"""
        longitude = Longitude(value=139.7671)

        result = longitude.to_float()

        assert isinstance(result, float)
        assert result == 139.7671

    def test_hashメソッドが正しく動作すること(self) -> None:
        """__hash__メソッドが正しく動作することを確認"""
        longitude1 = Longitude(value=139.7671)
        longitude2 = Longitude(value=139.7671)
        longitude3 = Longitude(value=139.7672)

        # 同じ値の場合は同じハッシュ値を持つ
        assert hash(longitude1) == hash(longitude2)
        # 異なる値の場合は異なるハッシュ値を持つ(通常)
        assert hash(longitude1) != hash(longitude3)

    def test_不変性が保証されていること(self) -> None:
        """frozen=Trueにより不変性が保証されていることを確認"""
        longitude = Longitude(value=139.7671)

        # 属性の変更を試みるとエラーが発生する
        from dataclasses import FrozenInstanceError

        with pytest.raises(FrozenInstanceError):
            longitude.value = 140.0  # type: ignore[misc]

    def test_異なる値のLongitudeが等しくないこと(self) -> None:
        """異なる値のLongitudeが等しくないことを確認"""
        longitude1 = Longitude(value=139.7671)
        longitude2 = Longitude(value=139.7672)

        assert longitude1 != longitude2

    def test_同じ値のLongitudeが等しいこと(self) -> None:
        """同じ値のLongitudeが等しいことを確認"""
        longitude1 = Longitude(value=139.7671)
        longitude2 = Longitude(value=139.7671)

        assert longitude1 == longitude2

    def test_様々な有効な値で作成できること(self) -> None:
        """様々な有効な値でLongitudeを作成できることを確認"""
        test_values = [
            -180.0,
            -90.0,
            0.0,
            90.0,
            180.0,
            139.7671,
            -139.7671,
        ]

        for value in test_values:
            longitude = Longitude(value=value)
            assert longitude.value == value
            assert longitude.to_float() == value


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
        from dataclasses import FrozenInstanceError

        with pytest.raises(FrozenInstanceError):
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
            assert coordinate.to_float_tuple() == (lat, lng)

    def test_LatitudeとLongitude値オブジェクトで様々な値を作成できること(self) -> None:
        """LatitudeとLongitude値オブジェクトで様々な値を作成できることを確認"""
        latitude = Latitude(value=35.6812)
        longitude = Longitude(value=139.7671)

        coordinate = Coordinate(latitude=latitude, longitude=longitude)

        assert coordinate.latitude == latitude
        assert coordinate.longitude == longitude
        assert coordinate.to_float_tuple() == (35.6812, 139.7671)
