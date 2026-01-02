"""polyline_mapperのテスト"""

import pytest

from app.domain.value_objects import Coordinate
from app.infrastructure.mappers import decode_polyline


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
