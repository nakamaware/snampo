"""longitudeのテスト"""

import pytest

from app.domain.value_objects.longitude import Longitude


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

    def test_serialize_modelメソッドが正しく動作すること(self) -> None:
        """serialize_modelメソッドが正しく動作することを確認"""
        longitude = Longitude(value=139.7671)

        result = longitude.serialize_model()

        assert isinstance(result, float)
        assert result == 139.7671

    def test_不変性が保証されていること(self) -> None:
        """frozen=Trueにより不変性が保証されていることを確認"""
        longitude = Longitude(value=139.7671)

        # 属性の変更を試みるとエラーが発生する
        from pydantic import ValidationError

        with pytest.raises(ValidationError):
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
