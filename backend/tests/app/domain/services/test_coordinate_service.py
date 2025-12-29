"""coordinate_serviceのテスト"""

import math

from geopy.distance import geodesic

from app.domain.services.coordinate_service import generate_random_point
from app.domain.value_objects import Coordinate


class TestGenerateRandomPoint:
    """generate_random_point関数のテスト"""

    # テストで使用する共通の座標
    DEFAULT_LATITUDE = 35.6870958
    DEFAULT_LONGITUDE = 139.8133963

    # ========== 基本的な動作確認(正常系) ==========

    def test_戻り値がCoordinate型であること(self) -> None:
        """戻り値がCoordinate型であることを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
        radius_m = 100.0

        point = generate_random_point(center, radius_m)

        assert isinstance(point, Coordinate)

    def test_指定された円周上の点が生成されること(self) -> None:
        """指定された円周上の点が生成されることを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
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

    def test_半径0の場合は中心点と同じ座標が生成されること(self) -> None:
        """半径0の場合、中心点と同じ座標が生成されることを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
        radius_m = 0.0

        point = generate_random_point(center, radius_m)

        # 浮動小数点数の誤差を考慮して、ほぼ同じ座標であることを確認
        assert abs(point.latitude - center.latitude) < 1e-6
        assert abs(point.longitude - center.longitude) < 1e-6

    # ========== ランダム性・分布の確認 ==========

    def test_複数回実行すると異なる結果が得られること(self) -> None:
        """複数回実行すると異なる結果が得られることを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
        radius_m = 1000.0

        points = [generate_random_point(center, radius_m) for _ in range(10)]

        # すべての点が異なることを確認 (確率的に異なる)
        unique_points = set(points)
        assert len(unique_points) > 1, "複数回実行しても同じ点が生成されています"

    def test_全方向に点が生成されること(self) -> None:
        """ランダムな角度が均等に分布し、全方向に点が生成されることを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
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

    # ========== 様々な入力値での動作確認 ==========

    def test_様々な半径で正しく動作すること(self) -> None:
        """様々な半径で正しく動作することを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
        radii = [10.0, 100.0, 1000.0, 10000.0, 100000.0]

        for radius_m in radii:
            point = generate_random_point(center, radius_m)
            assert -90 <= point.latitude <= 90
            assert -180 <= point.longitude <= 180

    def test_様々な半径での距離の精度検証(self) -> None:
        """様々な半径での距離の精度を検証"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
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

    def test_異なる中心点で正しく動作すること(self) -> None:
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

    # ========== 境界値・エッジケース ==========

    def test_生成された座標が有効な範囲内であること(self) -> None:
        """生成された座標が有効な範囲内であることを確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
        radius_m = 1000.0

        for _ in range(100):
            point = generate_random_point(center, radius_m)

            # 緯度・経度が有効な範囲内であることを確認
            assert -90 <= point.latitude <= 90
            assert -180 <= point.longitude <= 180

    def test_経度の境界値での動作(self) -> None:
        """経度の境界値(-180度、180度)での動作を確認"""
        # 経度-180度
        center_west = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=-180.0)
        # 経度180度
        center_east = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=180.0)

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

    def test_極点での動作(self) -> None:
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

    def test_非常に大きな半径での動作(self) -> None:
        """非常に大きな半径(地球の半径レベル)での動作を確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
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

    def test_負の半径の場合の動作(self) -> None:
        """負の半径が指定された場合の動作を確認"""
        center = Coordinate(latitude=self.DEFAULT_LATITUDE, longitude=self.DEFAULT_LONGITUDE)
        radius_m = -1000.0

        # 負の半径でも動作することを確認(geopyは負の距離を処理できる)
        point = generate_random_point(center, radius_m)

        # 座標が有効な範囲内であることを確認
        assert -90 <= point.latitude <= 90
        assert -180 <= point.longitude <= 180
