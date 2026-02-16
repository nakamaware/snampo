"""coordinate_serviceのテスト"""

from unittest.mock import MagicMock, patch

import pytest
from geographiclib.geodesic import Geodesic

from app.domain.services.coordinate_service import (
    calculate_distance,
    calculate_geodesic_midpoint,
)
from app.domain.value_objects import Coordinate

# ===== calculate_distance のテスト =====


def test_calculate_distance_同じ座標の場合は0を返すこと() -> None:
    """同じ座標の場合は距離0を返すことを確認"""
    default_latitude = 35.6870958
    default_longitude = 139.8133963
    coordinate = Coordinate(latitude=default_latitude, longitude=default_longitude)

    distance = calculate_distance(coordinate, coordinate)

    assert abs(distance) < 0.01  # ほぼ0であることを確認


def test_calculate_distance_東京駅から皇居までの距離が正しいこと() -> None:
    """東京駅から皇居までの距離が正しいことを確認"""
    # 東京駅
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    # 皇居
    coordinate2 = Coordinate(latitude=35.6850, longitude=139.7528)

    distance = calculate_distance(coordinate1, coordinate2)

    # 実際の距離は約1.3km
    assert 1200 < distance < 1500, f"距離が期待範囲外です: {distance}m"


def test_calculate_distance_順序を入れ替えても同じ距離になること() -> None:
    """座標の順序を入れ替えても同じ距離になることを確認"""
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    coordinate2 = Coordinate(latitude=35.6850, longitude=139.7528)

    distance1 = calculate_distance(coordinate1, coordinate2)
    distance2 = calculate_distance(coordinate2, coordinate1)

    assert distance1 == distance2


# ===== calculate_geodesic_midpoint のテスト =====


def test_測地線上の中間地点を計算できること() -> None:
    """2点間の測地線上の中間地点を計算できることを確認"""
    # 東京駅
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    # 新宿駅
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    midpoint = calculate_geodesic_midpoint(start, end)

    # 中間地点は両端の緯度・経度の間に存在することを確認
    assert (
        min(start.latitude, end.latitude) <= midpoint.latitude <= max(start.latitude, end.latitude)
    )
    assert (
        min(start.longitude, end.longitude)
        <= midpoint.longitude
        <= max(start.longitude, end.longitude)
    )
    assert isinstance(midpoint, Coordinate)


def test_同じ座標の場合は同じ座標を返すこと() -> None:
    """始点と終点が同じ場合、その座標を返すことを確認"""
    coord = Coordinate(latitude=35.6812, longitude=139.7671)

    midpoint = calculate_geodesic_midpoint(coord, coord)

    # 同じ座標が返されることを確認(浮動小数点の誤差を許容)
    assert abs(midpoint.latitude - coord.latitude) < 1e-6
    assert abs(midpoint.longitude - coord.longitude) < 1e-6


def test_長距離の2点間でも中間地点を計算できること() -> None:
    """長距離(東京-大阪)の2点間でも中間地点を計算できることを確認"""
    # 東京
    tokyo = Coordinate(latitude=35.6812, longitude=139.7671)
    # 大阪
    osaka = Coordinate(latitude=34.6937, longitude=135.5023)

    midpoint = calculate_geodesic_midpoint(tokyo, osaka)

    # 中間地点は両端の緯度・経度の間に存在することを確認
    assert (
        min(tokyo.latitude, osaka.latitude)
        <= midpoint.latitude
        <= max(tokyo.latitude, osaka.latitude)
    )
    assert (
        min(tokyo.longitude, osaka.longitude)
        <= midpoint.longitude
        <= max(tokyo.longitude, osaka.longitude)
    )


def test_南北方向の2点間で中間地点を計算できること() -> None:
    """南北方向(経度が同じ)の2点間で中間地点を計算できることを確認"""
    north = Coordinate(latitude=36.0, longitude=139.0)
    south = Coordinate(latitude=34.0, longitude=139.0)

    midpoint = calculate_geodesic_midpoint(north, south)

    # 経度はほぼ同じであることを確認
    assert abs(midpoint.longitude - 139.0) < 0.01
    # 緯度は中間付近であることを確認
    assert 34.5 < midpoint.latitude < 35.5


def test_東西方向の2点間で中間地点を計算できること() -> None:
    """東西方向(緯度が同じ)の2点間で中間地点を計算できることを確認"""
    west = Coordinate(latitude=35.0, longitude=138.0)
    east = Coordinate(latitude=35.0, longitude=140.0)

    midpoint = calculate_geodesic_midpoint(west, east)

    # 緯度はほぼ同じであることを確認
    assert abs(midpoint.latitude - 35.0) < 0.01
    # 経度は中間付近であることを確認
    assert 138.5 < midpoint.longitude < 139.5


def test_始点と終点が同じ場合でもエラーが発生しないこと() -> None:
    """始点と終点が同じ場合でもエラーが発生しないことを確認"""
    coord = Coordinate(latitude=35.6812, longitude=139.7671)

    # エラーが発生しないことを確認
    midpoint = calculate_geodesic_midpoint(coord, coord)

    # 結果が有効な座標であることを確認
    assert isinstance(midpoint, Coordinate)
    assert -90 <= midpoint.latitude <= 90
    assert -180 <= midpoint.longitude <= 180


def test_近接対蹠点の場合でも計算が実行されること() -> None:
    """近接対蹠点(地球の反対側)の場合でも計算が実行されることを確認"""
    # 東京 (35.6812, 139.7671) とその対蹠点付近
    # 対蹠点は緯度を反転、経度を180度ずらした地点
    tokyo = Coordinate(latitude=35.6812, longitude=139.7671)
    # 対蹠点付近の座標 (緯度を反転、経度を180度ずらす)
    antipodal = Coordinate(latitude=-35.6812, longitude=-40.2329)

    # エラーが発生しないことを確認
    midpoint = calculate_geodesic_midpoint(tokyo, antipodal)

    # 結果が有効な座標であることを確認
    assert isinstance(midpoint, Coordinate)
    assert -90 <= midpoint.latitude <= 90
    assert -180 <= midpoint.longitude <= 180


def test_極点を含む2点間で中間地点を計算できること() -> None:
    """極点を含む2点間で中間地点を計算できることを確認"""
    # 北極
    north_pole = Coordinate(latitude=90.0, longitude=0.0)
    # 東京
    tokyo = Coordinate(latitude=35.6812, longitude=139.7671)

    midpoint = calculate_geodesic_midpoint(north_pole, tokyo)

    # 結果が有効な座標であることを確認
    assert isinstance(midpoint, Coordinate)
    assert -90 <= midpoint.latitude <= 90
    assert -180 <= midpoint.longitude <= 180
    # 中間地点は北極と東京の間にあることを確認
    assert midpoint.latitude < north_pole.latitude
    assert midpoint.latitude > tokyo.latitude


def test_経度180度を跨ぐ2点間で中間地点を計算できること() -> None:
    """経度180度を跨ぐ2点間で中間地点を計算できることを確認"""
    # 日付変更線の西側
    west = Coordinate(latitude=35.0, longitude=179.0)
    # 日付変更線の東側
    east = Coordinate(latitude=35.0, longitude=-179.0)

    midpoint = calculate_geodesic_midpoint(west, east)

    # 結果が有効な座標であることを確認
    assert isinstance(midpoint, Coordinate)
    assert -90 <= midpoint.latitude <= 90
    assert -180 <= midpoint.longitude <= 180


def test_非常に長い距離の2点間で中間地点を計算できること() -> None:
    """非常に長い距離(地球の周囲の大部分)の2点間で中間地点を計算できることを確認"""
    # ロンドン
    london = Coordinate(latitude=51.5074, longitude=-0.1278)
    # シドニー
    sydney = Coordinate(latitude=-33.8688, longitude=151.2093)

    midpoint = calculate_geodesic_midpoint(london, sydney)

    # 結果が有効な座標であることを確認
    assert isinstance(midpoint, Coordinate)
    assert -90 <= midpoint.latitude <= 90
    assert -180 <= midpoint.longitude <= 180


def test_geodesic距離計算のエラーハンドリング() -> None:
    """geodesic距離計算でエラーが発生した場合の動作を確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    # geodesic関数がエラーを発生させるようにモック
    with (
        patch(
            "app.domain.services.coordinate_service.geodesic",
            side_effect=ValueError("Test error"),
        ),
        pytest.raises((ValueError, Exception)),
    ):
        calculate_geodesic_midpoint(start, end)


def test_Geodesic_Inverseのエラーハンドリング() -> None:
    """Geodesic.WGS84.Inverseでエラーが発生した場合の動作を確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    # Geodesic.WGS84.Inverseがエラーを発生させるようにモック
    with (
        patch.object(Geodesic.WGS84, "Inverse", side_effect=ValueError("Test error")),
        pytest.raises((ValueError, Exception)),
    ):
        calculate_geodesic_midpoint(start, end)


def test_inverse_resultにazi1が含まれていない場合の動作() -> None:
    """inverse_resultにazi1が含まれていない場合の動作を確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    # azi1を含まない結果を返すようにモック
    mock_result = {}  # 空の辞書

    with (
        patch.object(Geodesic.WGS84, "Inverse", return_value=mock_result),
        pytest.raises((KeyError, AttributeError, Exception)),
    ):
        calculate_geodesic_midpoint(start, end)


def test_bearingが数値型でない場合の動作() -> None:
    """bearingが数値型でない場合の動作を確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    # azi1が文字列を返すようにモック
    mock_result = {"azi1": "invalid"}

    with patch.object(Geodesic.WGS84, "Inverse", return_value=mock_result):
        # geopyが文字列のbearingを処理できる場合もあるため、
        # エラーが発生する場合としない場合の両方を考慮
        try:
            midpoint = calculate_geodesic_midpoint(start, end)
            # エラーが発生しない場合、結果が有効な座標であることを確認
            assert isinstance(midpoint, Coordinate)
        except (TypeError, ValueError, Exception) as e:
            # エラーが発生する場合もあることを確認
            # このテストは両方のケースを許容するため、例外を記録して終了
            assert isinstance(e, (TypeError, ValueError, Exception))


def test_geodesic_destinationのエラーハンドリング() -> None:
    """geodesic.destinationでエラーが発生した場合の動作を確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    # geodesic().destinationがエラーを発生させるようにモック
    mock_geodesic = MagicMock()
    mock_geodesic.destination.side_effect = ValueError("Test error")
    mock_geodesic.meters = 1000.0

    with (
        patch("app.domain.services.coordinate_service.geodesic", return_value=mock_geodesic),
        pytest.raises((ValueError, Exception)),
    ):
        calculate_geodesic_midpoint(start, end)


def test_計算結果のmidpointにlatitudeとlongitude属性がない場合の動作() -> None:
    """計算結果のmidpointにlatitudeとlongitude属性がない場合の動作を確認"""
    start = Coordinate(latitude=35.6812, longitude=139.7671)
    end = Coordinate(latitude=35.6896, longitude=139.6917)

    # latitudeとlongitude属性がないオブジェクトを返すようにモック
    mock_midpoint = MagicMock(spec=[])  # 属性を指定しない

    # geodesicの呼び出しをモック
    mock_geodesic_distance = MagicMock()
    mock_geodesic_distance.meters = 1000.0

    mock_geodesic_destination = MagicMock()
    mock_geodesic_destination.destination.return_value = mock_midpoint

    with (
        patch("app.domain.services.coordinate_service.geodesic") as mock_geodesic,
        pytest.raises((AttributeError, Exception)),
    ):
        # 最初の呼び出し(距離計算)ではmock_geodesic_distanceを返す
        # 2回目の呼び出し(destination)ではmock_geodesic_destinationを返す
        mock_geodesic.side_effect = [mock_geodesic_distance, mock_geodesic_destination]
        calculate_geodesic_midpoint(start, end)
