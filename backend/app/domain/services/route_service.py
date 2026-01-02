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

    Raises:
        ValueError: route_coordinatesが空またはNoneの場合
    """
    if route_coordinates is None or len(route_coordinates) == 0:
        raise ValueError("route_coordinates must be a non-empty list")

    midpoint_index = len(route_coordinates) // 2
    return route_coordinates[midpoint_index]
