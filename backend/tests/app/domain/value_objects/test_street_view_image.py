"""street_view_imageのテスト"""

import pytest

from app.domain.value_objects.coordinate import Coordinate
from app.domain.value_objects.street_view_image import StreetViewImage


def test_有効な値で作成できること() -> None:
    """有効な値でStreetViewImageを作成できることを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"

    street_view_image = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )

    assert street_view_image.metadata_coordinate == metadata_coordinate
    assert street_view_image.original_coordinate == original_coordinate
    assert street_view_image.image_data == image_data


def test_hashメソッドが正しく動作すること() -> None:
    """__hash__メソッドが正しく動作することを確認"""
    metadata_coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate1 = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data1 = b"fake image data"

    metadata_coordinate2 = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate2 = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data2 = b"fake image data"

    metadata_coordinate3 = Coordinate(latitude=35.6814, longitude=139.7673)
    original_coordinate3 = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data3 = b"fake image data"

    street_view_image1 = StreetViewImage(
        metadata_coordinate=metadata_coordinate1,
        original_coordinate=original_coordinate1,
        image_data=image_data1,
    )
    street_view_image2 = StreetViewImage(
        metadata_coordinate=metadata_coordinate2,
        original_coordinate=original_coordinate2,
        image_data=image_data2,
    )
    street_view_image3 = StreetViewImage(
        metadata_coordinate=metadata_coordinate3,
        original_coordinate=original_coordinate3,
        image_data=image_data3,
    )

    # 同じ値の場合は同じハッシュ値を持つ
    assert hash(street_view_image1) == hash(street_view_image2)
    # 異なる値の場合は異なるハッシュ値を持つ(通常)
    assert hash(street_view_image1) != hash(street_view_image3)


def test_同じ値のStreetViewImageが等しいこと() -> None:
    """同じ値のStreetViewImageが等しいことを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"

    street_view_image1 = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )
    street_view_image2 = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )

    assert street_view_image1 == street_view_image2


def test_異なる値のStreetViewImageが等しくないこと() -> None:
    """異なる値のStreetViewImageが等しくないことを確認"""
    metadata_coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate1 = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data1 = b"fake image data"

    metadata_coordinate2 = Coordinate(latitude=35.6814, longitude=139.7673)
    original_coordinate2 = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data2 = b"fake image data"

    metadata_coordinate3 = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate3 = Coordinate(latitude=35.6815, longitude=139.7674)
    image_data3 = b"fake image data"

    metadata_coordinate4 = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate4 = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data4 = b"different image data"

    street_view_image1 = StreetViewImage(
        metadata_coordinate=metadata_coordinate1,
        original_coordinate=original_coordinate1,
        image_data=image_data1,
    )
    street_view_image2 = StreetViewImage(
        metadata_coordinate=metadata_coordinate2,
        original_coordinate=original_coordinate2,
        image_data=image_data2,
    )
    street_view_image3 = StreetViewImage(
        metadata_coordinate=metadata_coordinate3,
        original_coordinate=original_coordinate3,
        image_data=image_data3,
    )
    street_view_image4 = StreetViewImage(
        metadata_coordinate=metadata_coordinate4,
        original_coordinate=original_coordinate4,
        image_data=image_data4,
    )

    assert street_view_image1 != street_view_image2  # metadata_coordinateが異なる
    assert street_view_image1 != street_view_image3  # original_coordinateが異なる
    assert street_view_image1 != street_view_image4  # image_dataが異なる


def test_異なる型のオブジェクトと等しくないこと() -> None:
    """異なる型のオブジェクトと等しくないことを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"

    street_view_image = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )

    assert street_view_image != "not a street view image"
    assert street_view_image != 123
    assert street_view_image != (metadata_coordinate, original_coordinate, image_data)


def test_不変性が保証されていること() -> None:
    """frozen=Trueにより不変性が保証されていることを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"

    street_view_image = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )

    # 属性の変更を試みるとエラーが発生する
    with pytest.raises((TypeError, ValueError)):
        street_view_image.metadata_coordinate = Coordinate(latitude=36.0, longitude=140.0)  # type: ignore[misc]

    with pytest.raises((TypeError, ValueError)):
        street_view_image.image_data = b"new data"  # type: ignore[misc]


def test_空の画像データで作成できること() -> None:
    """空の画像データでStreetViewImageを作成できることを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b""

    street_view_image = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )

    assert street_view_image.image_data == b""


def test_同じ座標でも画像データが異なれば異なるオブジェクトになること() -> None:
    """同じ座標でも画像データが異なれば異なるオブジェクトになることを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data1 = b"image data 1"
    image_data2 = b"image data 2"

    street_view_image1 = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data1,
    )
    street_view_image2 = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data2,
    )

    assert street_view_image1 != street_view_image2
    assert hash(street_view_image1) != hash(street_view_image2)


def test_headingフィールドがオプショナルであること() -> None:
    """headingフィールドがオプショナルで、デフォルト値がNoneであることを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"

    street_view_image = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
    )

    assert street_view_image.heading is None


def test_headingフィールドを指定できること() -> None:
    """headingフィールドを指定できることを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"
    heading = 90.0

    street_view_image = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
        heading=heading,
    )

    assert street_view_image.heading == heading


def test_headingが異なる場合は異なるハッシュ値を持つこと() -> None:
    """headingが異なる場合は異なるハッシュ値を持つことを確認"""
    metadata_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    original_coordinate = Coordinate(latitude=35.6813, longitude=139.7672)
    image_data = b"fake image data"

    street_view_image1 = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
        heading=90.0,
    )
    street_view_image2 = StreetViewImage(
        metadata_coordinate=metadata_coordinate,
        original_coordinate=original_coordinate,
        image_data=image_data,
        heading=180.0,
    )

    assert hash(street_view_image1) != hash(street_view_image2)
