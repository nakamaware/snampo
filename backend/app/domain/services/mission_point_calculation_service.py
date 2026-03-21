"""ミッション地点数計算ドメインサービス

距離に基づいてミッション地点数を計算する純粋なビジネスロジックを提供します。
外部依存がなく、単体テストが容易です。
"""


def calculate_mission_point_count(radius_m: int) -> int:
    """散歩の半径距離から中間ミッション地点数を計算する

    ビジネスルール:
    - 500m以下: 2件
    - 500m超〜1km以下: 4件
    - 1km超〜1.5km以下: 6件
    - 500m単位で2件ずつ増加

    Args:
        radius_m: 散歩の半径距離(メートル)

    Returns:
        中間ミッション地点数 (目的地を除く)

    Examples:
        >>> calculate_mission_point_count(500)
        2
        >>> calculate_mission_point_count(1000)
        4
        >>> calculate_mission_point_count(1001)
        6
        >>> calculate_mission_point_count(1500)
        6
    """
    if radius_m <= 0:
        raise ValueError("radius_m must be positive")

    # 500mごとに2件の中間ミッション地点を設定
    base_distance = 500  # 基準距離(m)
    points_per_base = 2  # 基準距離あたりの地点数

    # 切り上げで計算(500m以下で2件、501-1000mで4件、...)
    multiplier = (radius_m + base_distance - 1) // base_distance
    return multiplier * points_per_base
