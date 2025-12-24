"""ルート計算ドメインサービス

ルートに関するビジネスロジックを提供します。
"""

from app.domain.value_objects import Coordinate


def calculate_midpoint(route_coordinates: list[Coordinate]) -> Coordinate:
    """ルート座標リストから中間地点を計算

    Args:
        route_coordinates: ルートの座標リスト

    Returns:
        Coordinate: 中間地点の座標
    """
    midpoint_index = len(route_coordinates) // 2
    return route_coordinates[midpoint_index]
