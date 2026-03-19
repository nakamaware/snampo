"""座標計算ドメインサービス

座標に関するビジネスロジックを提供します。
"""

from geographiclib.geodesic import Geodesic
from geopy.distance import geodesic

from app.domain.value_objects import Coordinate


def calculate_distance(start: Coordinate, end: Coordinate) -> float:
    """2点間の測地線距離を計算

    地球表面上の最短経路(測地線)に沿った距離をメートル単位で返します。

    Args:
        start: 始点の座標
        end: 終点の座標

    Returns:
        float: 2点間の距離 (メートル単位)
    """
    start_point = (start.latitude, start.longitude)
    end_point = (end.latitude, end.longitude)

    distance = geodesic(start_point, end_point)
    return distance.meters


def calculate_bearing(start: Coordinate, end: Coordinate) -> float:
    """2点間の方位角 (bearing) を計算

    始点から終点への方位角を計算します。
    北が0度、東が90度、南が180度、西が270度の時計回りの角度を返します。

    Args:
        start: 始点の座標
        end: 終点の座標

    Returns:
        float: 方位角 (0-360度)
    """
    if start == end:
        return 0.0

    # geopyには方位角を直接取得するメソッドがないため、geographiclibを使用
    inverse_result = Geodesic.WGS84.Inverse(
        start.latitude, start.longitude, end.latitude, end.longitude
    )
    bearing = inverse_result["azi1"]

    # 負の値の場合は360度を加算して0-360度の範囲に正規化
    if bearing < 0:
        bearing += 360.0

    return bearing


def divide_route_into_segments(
    start: Coordinate, end: Coordinate, num_segments: int
) -> list[Coordinate]:
    """2地点間のルートを測地線上で等間隔の中間地点に分割する

    測地線(地球表面上の最短経路)に沿って、等間隔に分割された中間地点を計算します。
    単純な緯度経度の線形補間ではなく、実際の地球表面上での正確な分割点を返します。

    スタート地点とエンド地点は含まれません。

    Args:
        start: 開始地点
        end: 終了地点
        num_segments: 分割数(中間地点の数)

    Returns:
        中間地点のリスト(num_segments個)

    Raises:
        ValueError: num_segmentsが0以下の場合

    Examples:
        >>> start = Coordinate(latitude=35.6812, longitude=139.7671)  # 東京タワー
        >>> end = Coordinate(latitude=35.7101, longitude=139.8107)    # スカイツリー
        >>> points = divide_route_into_segments(start, end, 3)
        >>> len(points)
        3
        >>> # 3つの中間地点が測地線上に等間隔で配置される
    """
    if num_segments <= 0:
        raise ValueError("num_segments must be positive")

    # 2点間の測地線情報を取得(距離と方位角)
    inverse_result = Geodesic.WGS84.Inverse(
        start.latitude, start.longitude, end.latitude, end.longitude
    )
    total_distance = inverse_result["s12"]  # 総距離(メートル)
    bearing = inverse_result["azi1"]  # 方位角

    intermediate_points = []
    start_point = (start.latitude, start.longitude)

    for i in range(1, num_segments + 1):
        # 0から1の間で等間隔の割合を計算
        # i=1のとき ratio=1/(num_segments+1)
        # i=2のとき ratio=2/(num_segments+1), ...
        ratio = i / (num_segments + 1)

        # 始点からの距離を計算
        distance_from_start = total_distance * ratio

        # 測地線上の指定距離・方位角の地点を計算
        point = geodesic(meters=distance_from_start).destination(start_point, bearing)

        intermediate_points.append(Coordinate(latitude=point.latitude, longitude=point.longitude))

    return intermediate_points
