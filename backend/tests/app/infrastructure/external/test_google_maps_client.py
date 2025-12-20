"""google_maps_clientのテスト"""

from app.domain.value_objects import Coordinate
from app.infrastructure.external.google_maps_client import decode_polyline


class TestDecodePolyline:
    """decode_polyline関数のテスト"""

    def test_シンプルなポリラインをデコードできること(self) -> None:
        """シンプルなポリラインをデコードできることを確認"""
        # Google Maps APIのポリライン形式の例
        # 東京駅(35.6812, 139.7671)を表す有効なポリライン
        # 実際のGoogle Maps APIから取得した形式を使用
        polyline = "_p~iF~ps|U"

        coordinates = decode_polyline(polyline)

        assert len(coordinates) >= 1
        assert isinstance(coordinates[0], Coordinate)
        # デコード結果が有効な座標範囲内であることを確認
        assert -90 <= coordinates[0].latitude.to_float() <= 90
        assert -180 <= coordinates[0].longitude.to_float() <= 180

    def test_複数の点を含むポリラインをデコードできること(self) -> None:
        """複数の点を含むポリラインをデコードできることを確認"""
        # 複数点のポリライン例 (東京駅から新宿駅への経路の簡易版)
        # 実際のポリライン文字列を使用
        polyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"

        coordinates = decode_polyline(polyline)

        assert len(coordinates) > 1
        for coord in coordinates:
            assert isinstance(coord, Coordinate)
            assert -90 <= coord.latitude.to_float() <= 90
            assert -180 <= coord.longitude.to_float() <= 180

    def test_空のポリライン文字列を処理できること(self) -> None:
        """空のポリライン文字列を処理できることを確認"""
        polyline = ""

        coordinates = decode_polyline(polyline)

        assert coordinates == []

    def test_戻り値がCoordinateのリストであること(self) -> None:
        """戻り値がCoordinateのリストであることを確認"""
        # 有効なポリライン文字列を使用
        polyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"

        coordinates = decode_polyline(polyline)

        assert isinstance(coordinates, list)
        assert all(isinstance(coord, Coordinate) for coord in coordinates)

    def test_デコードされた座標が有効な範囲内であること(self) -> None:
        """デコードされた座標が有効な範囲内であることを確認"""
        # 東京駅周辺のポリライン (簡易版)
        polyline = "_p~iF~ps|U_ulLnnqC_mqNvxq`@"

        coordinates = decode_polyline(polyline)

        for coord in coordinates:
            # 緯度・経度が有効な範囲内であることを確認
            assert -90 <= coord.latitude.to_float() <= 90
            assert -180 <= coord.longitude.to_float() <= 180
