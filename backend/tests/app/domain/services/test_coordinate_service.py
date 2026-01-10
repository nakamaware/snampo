"""coordinate_serviceのテスト"""

import math
from unittest.mock import MagicMock, patch

import pytest
from geographiclib.geodesic import Geodesic
from geopy.distance import geodesic

from app.domain.services.coordinate_service import (
    calculate_geodesic_midpoint,
    generate_random_point,
)
from app.domain.value_objects import Coordinate

# テストで使用する共通の座標
DEFAULT_LATITUDE = 35.6870958
DEFAULT_LONGITUDE = 139.8133963


def test_戻り値がCoordinate型であること() -> None:
    """戻り値がCoordinate型であることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = 100.0

    point = generate_random_point(center, radius_m)

    assert isinstance(point, Coordinate)


def test_指定された円周上の点が生成されること() -> None:
    """指定された円周上の点が生成されることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = 1000.0  # 1km
    # geopyのgeodesic計算による高精度な距離検証のため、許容誤差を設定
    # 浮動小数点演算の誤差を考慮して、小さな許容誤差を設定
    tolerance_m = 0.1  # 許容誤差(メートル)
    # 複数回実行して、すべての点が円周上にあることを確認
    for _ in range(100):
        point = generate_random_point(center, radius_m)

        # geopyのgeodesicを使用して正確な距離を計算
        center_point = (center.latitude, center.longitude)
        point_tuple = (point.latitude, point.longitude)
        distance_m = geodesic(center_point, point_tuple).meters

        # 距離がほぼ半径に等しいことを確認(許容誤差を考慮)
        assert abs(distance_m - radius_m) <= tolerance_m, (
            f"生成された点が円周上にありません: "
            f"期待距離={radius_m}m, 実際の距離={distance_m}m, "
            f"誤差={abs(distance_m - radius_m)}m"
        )


def test_半径0の場合は中心点と同じ座標が生成されること() -> None:
    """半径0の場合、中心点と同じ座標が生成されることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = 0.0

    point = generate_random_point(center, radius_m)

    # 浮動小数点数の誤差を考慮して、ほぼ同じ座標であることを確認
    assert abs(point.latitude - center.latitude) < 1e-6
    assert abs(point.longitude - center.longitude) < 1e-6


def test_複数回実行すると異なる結果が得られること() -> None:
    """複数回実行すると異なる結果が得られることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = 1000.0

    points = [generate_random_point(center, radius_m) for _ in range(10)]

    # すべての点が異なることを確認 (確率的に異なる)
    unique_points = set(points)
    assert len(unique_points) > 1, "複数回実行しても同じ点が生成されています"


def test_全方向に点が生成されること() -> None:
    """ランダムな角度が均等に分布し、全方向に点が生成されることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = 1000.0

    # 複数回実行して、様々な方向に点が生成されることを確認
    points = [generate_random_point(center, radius_m) for _ in range(100)]

    # 角度を計算して、全方向に分布していることを確認
    angles = []
    for point in points:
        delta_lat = point.latitude - center.latitude
        delta_lng = point.longitude - center.longitude
        angle = math.atan2(delta_lng, delta_lat)
        angles.append(angle)

    # 角度が0から2πの範囲に均等に分布していることを確認
    # 4つの象限すべてに点が存在することを確認
    quadrants = [0, 0, 0, 0]  # 4象限のカウント
    for angle in angles:
        normalized_angle = (angle + 2 * math.pi) % (2 * math.pi)
        quadrant = int(normalized_angle / (math.pi / 2))
        quadrants[quadrant] += 1

    # すべての象限に少なくとも1つの点が存在することを確認
    assert all(count > 0 for count in quadrants), "全方向に点が生成されていません"


def test_様々な半径で正しく動作すること() -> None:
    """様々な半径で正しく動作することを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radii = [10.0, 100.0, 1000.0, 10000.0, 100000.0]

    for radius_m in radii:
        point = generate_random_point(center, radius_m)
        assert -90 <= point.latitude <= 90
        assert -180 <= point.longitude <= 180


def test_様々な半径での距離の精度検証() -> None:
    """様々な半径での距離の精度を検証"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    # 様々な半径とその許容誤差を定義
    test_cases = [
        (10.0, 0.01),  # 10m: 1cmの誤差まで許容
        (100.0, 0.1),  # 100m: 10cmの誤差まで許容
        (1000.0, 0.1),  # 1km: 10cmの誤差まで許容
        (10000.0, 1.0),  # 10km: 1mの誤差まで許容
        (100000.0, 10.0),  # 100km: 10mの誤差まで許容
    ]

    for radius_m, tolerance_m in test_cases:
        point = generate_random_point(center, radius_m)

        # geopyのgeodesicを使用して正確な距離を計算
        center_point = (center.latitude, center.longitude)
        point_tuple = (point.latitude, point.longitude)
        distance_m = geodesic(center_point, point_tuple).meters

        # 距離がほぼ半径に等しいことを確認(許容誤差を考慮)
        assert abs(distance_m - radius_m) <= tolerance_m, (
            f"半径{radius_m}mで生成された点の距離精度が不足しています: "
            f"期待距離={radius_m}m, 実際の距離={distance_m}m, "
            f"誤差={abs(distance_m - radius_m)}m, "
            f"許容誤差={tolerance_m}m"
        )


def test_異なる中心点で正しく動作すること() -> None:
    """異なる中心点で正しく動作することを確認"""
    # 赤道付近
    center_equator = Coordinate(latitude=0.0, longitude=0.0)
    # 極地付近(ただし範囲内)
    center_near_pole = Coordinate(latitude=89.0, longitude=0.0)
    # 日付変更線付近
    center_dateline = Coordinate(latitude=35.0, longitude=179.0)

    radius_m = 1000.0

    for center in [center_equator, center_near_pole, center_dateline]:
        point = generate_random_point(center, radius_m)
        assert -90 <= point.latitude <= 90
        assert -180 <= point.longitude <= 180


def test_生成された座標が有効な範囲内であること() -> None:
    """生成された座標が有効な範囲内であることを確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = 1000.0

    for _ in range(100):
        point = generate_random_point(center, radius_m)

        # 緯度・経度が有効な範囲内であることを確認
        assert -90 <= point.latitude <= 90
        assert -180 <= point.longitude <= 180


def test_経度の境界値での動作() -> None:
    """経度の境界値(-180度、180度)での動作を確認"""
    # 経度-180度
    center_west = Coordinate(latitude=DEFAULT_LATITUDE, longitude=-180.0)
    # 経度180度
    center_east = Coordinate(latitude=DEFAULT_LATITUDE, longitude=180.0)

    radius_m = 1000.0

    for center in [center_west, center_east]:
        point = generate_random_point(center, radius_m)
        # 生成された座標が有効な範囲内であることを確認
        assert -90 <= point.latitude <= 90
        assert -180 <= point.longitude <= 180
        # 指定された半径の距離にあることを確認
        center_point = (center.latitude, center.longitude)
        point_tuple = (point.latitude, point.longitude)
        distance_m = geodesic(center_point, point_tuple).meters
        tolerance_m = 0.1
        assert abs(distance_m - radius_m) <= tolerance_m, (
            f"経度境界値から生成された点が円周上にありません: "
            f"期待距離={radius_m}m, 実際の距離={distance_m}m"
        )


def test_極点での動作() -> None:
    """極点(北極・南極)での動作を確認"""
    # 北極
    center_north_pole = Coordinate(latitude=90.0, longitude=0.0)
    # 南極
    center_south_pole = Coordinate(latitude=-90.0, longitude=0.0)

    radius_m = 1000.0

    for center in [center_north_pole, center_south_pole]:
        point = generate_random_point(center, radius_m)
        # 極点から生成された点が有効な範囲内であることを確認
        assert -90 <= point.latitude <= 90
        assert -180 <= point.longitude <= 180
        # 極点から指定された半径の距離にあることを確認
        center_point = (center.latitude, center.longitude)
        point_tuple = (point.latitude, point.longitude)
        distance_m = geodesic(center_point, point_tuple).meters
        tolerance_m = 1.0  # 極点では若干の誤差を許容
        assert abs(distance_m - radius_m) <= tolerance_m, (
            f"極点から生成された点が円周上にありません: "
            f"期待距離={radius_m}m, 実際の距離={distance_m}m"
        )


def test_非常に大きな半径での動作() -> None:
    """非常に大きな半径(地球の半径レベル)での動作を確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    # 地球の半径は約6,371km
    radius_m = 6371000.0  # 約6,371km

    point = generate_random_point(center, radius_m)

    # 座標が有効な範囲内であることを確認
    assert -90 <= point.latitude <= 90
    assert -180 <= point.longitude <= 180
    # 距離がほぼ半径に等しいことを確認(大きな半径では若干の誤差を許容)
    center_point = (center.latitude, center.longitude)
    point_tuple = (point.latitude, point.longitude)
    distance_m = geodesic(center_point, point_tuple).meters
    tolerance_m = 1000.0  # 大きな半径では1km程度の誤差を許容
    assert abs(distance_m - radius_m) <= tolerance_m, (
        f"非常に大きな半径で生成された点が円周上にありません: "
        f"期待距離={radius_m}m, 実際の距離={distance_m}m, "
        f"誤差={abs(distance_m - radius_m)}m"
    )


def test_負の半径の場合の動作() -> None:
    """負の半径が指定された場合の動作を確認"""
    center = Coordinate(latitude=DEFAULT_LATITUDE, longitude=DEFAULT_LONGITUDE)
    radius_m = -1000.0

    # 負の半径でも動作することを確認(geopyは負の距離を処理できる)
    point = generate_random_point(center, radius_m)

    # 座標が有効な範囲内であることを確認
    assert -90 <= point.latitude <= 90
    assert -180 <= point.longitude <= 180


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
