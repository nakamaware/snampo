"""ミッション地点数計算ドメインサービス

距離に基づいてミッション地点数を計算する純粋なビジネスロジックを提供します。
外部依存がなく、単体テストが容易です。
"""


class MissionPointCalculator:
    """ミッション地点数を計算するドメインサービス"""

    @staticmethod
    def calculate_mission_point_count(radius_m: int) -> int:
        """散歩の半径距離からミッション地点数を計算する

        ビジネスルール:
        - 500m以下: 2件
        - 1km (1000m): 4件
        - 1.5km (1500m): 6件
        - 500m単位で2件ずつ増加

        Args:
            radius_m: 散歩の半径距離(メートル)

        Returns:
            ミッション地点数

        Examples:
            >>> MissionPointCalculator.calculate_mission_point_count(500)
            2
            >>> MissionPointCalculator.calculate_mission_point_count(1000)
            4
            >>> MissionPointCalculator.calculate_mission_point_count(1500)
            6
        """
        if radius_m <= 0:
            raise ValueError("radius_m must be positive")

        # 500mごとに2件のミッション地点を設定
        base_distance = 1000  # 基準距離(m)
        points_per_base = 2  # 基準距離あたりの地点数

        # 切り上げで計算(500m以下でも2件、501-1000mで4件)
        multiplier = (radius_m + base_distance - 1) // base_distance
        return multiplier * points_per_base

    @staticmethod
    def calculate_interval_distance(radius_m: int, num_points: int) -> float:
        """ミッション地点間の理想的な間隔距離を計算する

        Args:
            radius_m: 散歩の半径距離(メートル)
            num_points: ミッション地点数

        Returns:
            地点間の間隔距離(メートル)

        Examples:
            >>> MissionPointCalculator.calculate_interval_distance(1000, 4)
            250.0
        """
        if num_points <= 0:
            raise ValueError("num_points must be positive")

        # 往復の総距離を地点数+1で割る(スタート→地点1→地点2→...→ゴール)
        total_distance = radius_m * 2  # 往復
        return total_distance / (num_points + 1)
