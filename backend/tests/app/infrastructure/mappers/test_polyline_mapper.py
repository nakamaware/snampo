"""polyline_mapperのテスト"""

import pytest

from app.domain.value_objects import Coordinate
from app.infrastructure.mappers.polyline_mapper import (
    decode_polyline,
    encode_polyline,
    merge_polylines,
)


def test_シンプルなポリラインをデコードできること() -> None:
    """シンプルなポリラインをデコードできることを確認"""
    # Google Maps APIのポリライン形式の例
    # 東京駅(35.6812, 139.7671)を表す有効なポリライン
    # 実際のGoogle Maps APIから取得した形式を使用
    polyline = "_p~iF~ps|U"

    coordinates = decode_polyline(polyline)

    assert len(coordinates) >= 1
    assert isinstance(coordinates[0], Coordinate)
    # デコード結果が有効な座標範囲内であることを確認
    assert -90 <= coordinates[0].latitude <= 90
    assert -180 <= coordinates[0].longitude <= 180


def test_複数の点を含むポリラインをデコードできること() -> None:
    """複数の点を含むポリラインをデコードできることを確認"""
    # 複数点のポリライン例 (東京駅から新宿駅への経路の簡易版)
    # 実際のポリライン文字列を使用
    polyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"

    coordinates = decode_polyline(polyline)

    assert len(coordinates) > 1
    for coord in coordinates:
        assert isinstance(coord, Coordinate)
        assert -90 <= coord.latitude <= 90
        assert -180 <= coord.longitude <= 180


def test_空のポリライン文字列を処理できること() -> None:
    """空のポリライン文字列を処理できることを確認"""
    polyline = ""

    coordinates = decode_polyline(polyline)

    assert coordinates == []


def test_戻り値がCoordinateのリストであること() -> None:
    """戻り値がCoordinateのリストであることを確認"""
    # 有効なポリライン文字列を使用
    polyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"

    coordinates = decode_polyline(polyline)

    assert isinstance(coordinates, list)
    assert all(isinstance(coord, Coordinate) for coord in coordinates)


def test_デコードされた座標が有効な範囲内であること() -> None:
    """デコードされた座標が有効な範囲内であることを確認"""
    # 東京駅周辺のポリライン (簡易版)
    polyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"

    coordinates = decode_polyline(polyline)

    for coord in coordinates:
        # 緯度・経度が有効な範囲内であることを確認
        assert -90 <= coord.latitude <= 90
        assert -180 <= coord.longitude <= 180


def test_不完全なポリライン_緯度デコード中に終了する場合にValueErrorを発生させること() -> None:
    """不完全なポリライン(緯度デコード中に終了)でValueErrorが発生することを確認"""
    # 有効なポリラインの一部のみ(緯度デコード中に終了)
    # 1文字だけのポリラインは不完全(緯度の最初の文字で終了)
    incomplete_polyline = "_"

    with pytest.raises(ValueError) as exc_info:
        decode_polyline(incomplete_polyline)

    error_message = str(exc_info.value)
    assert "Invalid or incomplete polyline" in error_message
    assert "decoding latitude" in error_message
    assert "index" in error_message
    assert "current position" in error_message


def test_不完全なポリライン_経度デコード中に終了する場合にValueErrorを発生させること() -> None:
    """不完全なポリライン(経度デコード中に終了)でValueErrorが発生することを確認"""
    # 有効なポリラインの一部のみ(経度デコード中に終了)
    # "_p~iF~ps" は不完全(経度の途中で終了)
    incomplete_polyline = "_p~iF~ps"

    with pytest.raises(ValueError) as exc_info:
        decode_polyline(incomplete_polyline)

    error_message = str(exc_info.value)
    assert "Invalid or incomplete polyline" in error_message
    assert "decoding longitude" in error_message
    assert "index" in error_message
    assert "current position" in error_message


# ===== encode_polyline のテスト =====


def test_エンコードした結果をデコードすると元の座標に戻ること() -> None:
    """エンコードした結果をデコードすると元の座標に戻ることを確認"""
    original_coordinates = [
        Coordinate(latitude=35.6812, longitude=139.7671),  # 東京駅
        Coordinate(latitude=35.6896, longitude=139.6917),  # 新宿駅
    ]

    encoded = encode_polyline(original_coordinates)
    decoded = decode_polyline(encoded)

    assert len(decoded) == len(original_coordinates)
    for orig, dec in zip(original_coordinates, decoded, strict=True):
        # 精度は1e-5なので、誤差は最大1e-5程度
        assert abs(orig.latitude - dec.latitude) < 1e-4
        assert abs(orig.longitude - dec.longitude) < 1e-4


def test_空の座標リストをエンコードすると空文字列を返すこと() -> None:
    """空の座標リストをエンコードすると空文字列を返すことを確認"""
    coordinates: list[Coordinate] = []

    result = encode_polyline(coordinates)

    assert result == ""


def test_1つの座標をエンコードできること() -> None:
    """1つの座標をエンコードできることを確認"""
    coordinates = [Coordinate(latitude=35.6812, longitude=139.7671)]

    encoded = encode_polyline(coordinates)

    assert isinstance(encoded, str)
    assert len(encoded) > 0


def test_複数の座標をエンコードできること() -> None:
    """複数の座標をエンコードできることを確認"""
    coordinates = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.6896, longitude=139.6917),
        Coordinate(latitude=35.6586, longitude=139.7014),
    ]

    encoded = encode_polyline(coordinates)

    assert isinstance(encoded, str)
    assert len(encoded) > 0

    # デコードして検証
    decoded = decode_polyline(encoded)
    assert len(decoded) == 3


def test_負の座標を含む場合もエンコードできること() -> None:
    """負の座標を含む場合もエンコードできることを確認"""
    coordinates = [
        Coordinate(latitude=-33.8688, longitude=151.2093),  # シドニー
        Coordinate(latitude=-37.8136, longitude=144.9631),  # メルボルン
    ]

    encoded = encode_polyline(coordinates)
    decoded = decode_polyline(encoded)

    assert len(decoded) == 2
    # 精度チェック
    assert abs(decoded[0].latitude - coordinates[0].latitude) < 1e-4
    assert abs(decoded[0].longitude - coordinates[0].longitude) < 1e-4


# ===== merge_polylines のテスト =====


def test_2つのポリラインを結合できること() -> None:
    """2つのポリラインを結合できることを確認"""
    coords1 = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.6896, longitude=139.6917),
    ]
    coords2 = [
        Coordinate(latitude=35.6896, longitude=139.6917),  # 重複点
        Coordinate(latitude=35.6586, longitude=139.7014),
    ]

    polyline1 = encode_polyline(coords1)
    polyline2 = encode_polyline(coords2)

    merged = merge_polylines(polyline1, polyline2)
    decoded = decode_polyline(merged)

    # 重複点が除去されて3点になることを確認
    assert len(decoded) == 3


def test_重複点がない場合もポリラインを結合できること() -> None:
    """重複点がない場合もポリラインを結合できることを確認"""
    coords1 = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.6896, longitude=139.6917),
    ]
    coords2 = [
        Coordinate(latitude=35.6586, longitude=139.7014),  # 異なる点から開始
        Coordinate(latitude=35.6762, longitude=139.6503),
    ]

    polyline1 = encode_polyline(coords1)
    polyline2 = encode_polyline(coords2)

    merged = merge_polylines(polyline1, polyline2)
    decoded = decode_polyline(merged)

    # 重複点がないので4点になることを確認
    assert len(decoded) == 4


def test_空のポリラインと結合できること() -> None:
    """空のポリラインと結合できることを確認"""
    coords = [
        Coordinate(latitude=35.6812, longitude=139.7671),
        Coordinate(latitude=35.6896, longitude=139.6917),
    ]
    polyline = encode_polyline(coords)

    # 1番目が空
    merged1 = merge_polylines("", polyline)
    decoded1 = decode_polyline(merged1)
    assert len(decoded1) == 2

    # 2番目が空
    merged2 = merge_polylines(polyline, "")
    decoded2 = decode_polyline(merged2)
    assert len(decoded2) == 2


def test_両方空のポリラインを結合すると空文字列を返すこと() -> None:
    """両方空のポリラインを結合すると空文字列を返すことを確認"""
    merged = merge_polylines("", "")

    assert merged == ""
