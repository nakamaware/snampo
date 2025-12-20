"""latitudeのテスト"""

import pytest

from app.domain.value_objects.latitude import Latitude


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

    def test_serialize_modelメソッドが正しく動作すること(self) -> None:
        """serialize_modelメソッドが正しく動作することを確認"""
        latitude = Latitude(value=35.6812)

        result = latitude.serialize_model()

        assert isinstance(result, float)
        assert result == 35.6812

    def test_不変性が保証されていること(self) -> None:
        """frozen=Trueにより不変性が保証されていることを確認"""
        latitude = Latitude(value=35.6812)

        # 属性の変更を試みるとエラーが発生する
        from pydantic import ValidationError

        with pytest.raises(ValidationError):
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
