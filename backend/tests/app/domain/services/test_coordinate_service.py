"""coordinate_serviceのテスト"""

import math

from app.domain.services.coordinate_service import generate_random_point
from app.domain.value_objects import Coordinate


class TestGenerateRandomPoint:
    """generate_random_point関数のテスト"""

    def test_指定された円周上の点が生成されること(self) -> None:
        """指定された円周上の点が生成されることを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)  # 東京駅
        radius_m = 1000.0  # 1km
        # 実装と同じ計算方法で距離を検証するため、許容誤差は小さく設定
        tolerance_m = 1.0  # 許容誤差(メートル)
        # 複数回実行して、すべての点が円周上にあることを確認
        for _ in range(100):
            point = generate_random_point(center, radius_m)

            # 実装と同じ計算方法で距離を計算
            # 実装では radius_in_degrees = radius_m / 111300 で度に変換している
            delta_lat_deg = point.latitude - center.latitude
            delta_lng_deg = point.longitude - center.longitude
            # 度単位での距離を計算し、メートルに変換
            distance_deg = math.sqrt(delta_lat_deg**2 + delta_lng_deg**2)
            distance_m = distance_deg * 111300  # 1度 ≈ 111.3km

            # 距離がほぼ半径に等しいことを確認(許容誤差を考慮)
            assert abs(distance_m - radius_m) <= tolerance_m, (
                f"生成された点が円周上にありません: "
                f"期待距離={radius_m}m, 実際の距離={distance_m}m, "
                f"誤差={abs(distance_m - radius_m)}m"
            )

    def test_半径0の場合は中心点と同じ座標が生成されること(self) -> None:
        """半径0の場合、中心点と同じ座標が生成されることを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)
        radius_m = 0.0

        point = generate_random_point(center, radius_m)

        # 浮動小数点数の誤差を考慮して、ほぼ同じ座標であることを確認
        assert abs(point.latitude - center.latitude) < 1e-6
        assert abs(point.longitude - center.longitude) < 1e-6

    def test_戻り値がCoordinate型であること(self) -> None:
        """戻り値がCoordinate型であることを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)
        radius_m = 100.0

        point = generate_random_point(center, radius_m)

        assert isinstance(point, Coordinate)

    def test_複数回実行すると異なる結果が得られること(self) -> None:
        """複数回実行すると異なる結果が得られることを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)
        radius_m = 1000.0

        points = [generate_random_point(center, radius_m) for _ in range(10)]

        # すべての点が異なることを確認 (確率的に異なる)
        unique_points = set(points)
        assert len(unique_points) > 1, "複数回実行しても同じ点が生成されています"

    def test_生成された座標が有効な範囲内であること(self) -> None:
        """生成された座標が有効な範囲内であることを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)
        radius_m = 1000.0

        for _ in range(100):
            point = generate_random_point(center, radius_m)

            # 緯度・経度が有効な範囲内であることを確認
            assert -90 <= point.latitude <= 90
            assert -180 <= point.longitude <= 180

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

    def test_様々な半径で正しく動作すること(self) -> None:
        """様々な半径で正しく動作することを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)
        radii = [10.0, 100.0, 1000.0, 10000.0, 100000.0]

        for radius_m in radii:
            point = generate_random_point(center, radius_m)
            assert -90 <= point.latitude <= 90
            assert -180 <= point.longitude <= 180

    def test_全方向に点が生成されること(self) -> None:
        """ランダムな角度が均等に分布し、全方向に点が生成されることを確認"""
        center = Coordinate(latitude=35.6812, longitude=139.7671)
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
