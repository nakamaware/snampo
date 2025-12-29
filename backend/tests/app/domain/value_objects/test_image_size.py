"""image_sizeのテスト"""

import pytest
from pydantic import ValidationError

from app.domain.value_objects.image_size import ImageSize


class TestImageSize:
    """ImageSize値オブジェクトのテスト"""

    def test_有効な値で作成できること(self) -> None:
        """有効な値でImageSizeを作成できることを確認"""
        image_size = ImageSize(width=640, height=480)

        assert image_size.width == 640
        assert image_size.height == 480

    def test_to_stringメソッドが正しく動作すること(self) -> None:
        """to_stringメソッドが正しく動作することを確認"""
        image_size = ImageSize(width=640, height=480)

        result = image_size.to_string()

        assert isinstance(result, str)
        assert result == "640x480"

    def test_hashメソッドが正しく動作すること(self) -> None:
        """__hash__メソッドが正しく動作することを確認"""
        image_size1 = ImageSize(width=640, height=480)
        image_size2 = ImageSize(width=640, height=480)
        image_size3 = ImageSize(width=320, height=240)

        # 同じ値の場合は同じハッシュ値を持つ
        assert hash(image_size1) == hash(image_size2)
        # 異なる値の場合は異なるハッシュ値を持つ(通常)
        assert hash(image_size1) != hash(image_size3)

    def test_同じ値のImageSizeが等しいこと(self) -> None:
        """同じ値のImageSizeが等しいことを確認"""
        image_size1 = ImageSize(width=640, height=480)
        image_size2 = ImageSize(width=640, height=480)

        assert image_size1 == image_size2

    def test_異なる値のImageSizeが等しくないこと(self) -> None:
        """異なる値のImageSizeが等しくないことを確認"""
        image_size1 = ImageSize(width=640, height=480)
        image_size2 = ImageSize(width=320, height=240)
        image_size3 = ImageSize(width=640, height=240)

        assert image_size1 != image_size2
        assert image_size1 != image_size3

    def test_異なる型のオブジェクトと等しくないこと(self) -> None:
        """異なる型のオブジェクトと等しくないことを確認"""
        image_size = ImageSize(width=640, height=480)

        assert image_size != "not an image size"
        assert image_size != 123
        assert image_size != (640, 480)

    def test_不変性が保証されていること(self) -> None:
        """frozen=Trueにより不変性が保証されていることを確認"""
        image_size = ImageSize(width=640, height=480)

        # 属性の変更を試みるとエラーが発生する
        with pytest.raises((TypeError, ValueError)):
            image_size.width = 320  # type: ignore[misc]

    def test_無効な幅値でValidationErrorが発生すること(self) -> None:
        """無効な幅値でValidationErrorが発生することを確認"""
        with pytest.raises(ValidationError):
            ImageSize(width=0, height=480)

        with pytest.raises(ValidationError):
            ImageSize(width=-1, height=480)

        with pytest.raises(ValidationError):
            ImageSize(width=641, height=480)

    def test_無効な高さ値でValidationErrorが発生すること(self) -> None:
        """無効な高さ値でValidationErrorが発生することを確認"""
        with pytest.raises(ValidationError):
            ImageSize(width=640, height=0)

        with pytest.raises(ValidationError):
            ImageSize(width=640, height=-1)

        with pytest.raises(ValidationError):
            ImageSize(width=640, height=641)

    def test_境界値の幅で作成できること(self) -> None:
        """境界値の幅でImageSizeを作成できることを確認"""
        image_size1 = ImageSize(width=1, height=480)
        image_size2 = ImageSize(width=640, height=480)

        assert image_size1.width == 1
        assert image_size2.width == 640

    def test_境界値の高さで作成できること(self) -> None:
        """境界値の高さでImageSizeを作成できることを確認"""
        image_size1 = ImageSize(width=640, height=1)
        image_size2 = ImageSize(width=640, height=640)

        assert image_size1.height == 1
        assert image_size2.height == 640

    def test_様々な有効な値で作成できること(self) -> None:
        """様々な有効な値でImageSizeを作成できることを確認"""
        test_cases = [
            (1, 1),  # 最小値
            (640, 640),  # 最大値
            (320, 240),  # 一般的なサイズ
            (640, 480),  # VGA
            (128, 128),  # 正方形
        ]

        for width, height in test_cases:
            image_size = ImageSize(width=width, height=height)
            assert image_size.width == width
            assert image_size.height == height
            assert image_size.to_string() == f"{width}x{height}"
