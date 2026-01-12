"""ポリラインマッパー

Google Maps APIのポリライン形式をドメインオブジェクトに変換します。
"""

from app.domain.value_objects import Coordinate


def encode_polyline(coordinates: list[Coordinate]) -> str:
    """座標リストをGoogle Maps APIのポリライン形式にエンコード

    Args:
        coordinates: 座標リスト

    Returns:
        str: エンコードされたポリライン文字列
    """
    if not coordinates:
        return ""

    result: list[str] = []
    prev_lat = 0
    prev_lng = 0

    for coord in coordinates:
        # 緯度・経度を1e5倍して整数化
        lat = round(coord.latitude * 1e5)
        lng = round(coord.longitude * 1e5)

        # 差分を計算
        d_lat = lat - prev_lat
        d_lng = lng - prev_lng

        prev_lat = lat
        prev_lng = lng

        # 各差分をエンコード
        result.append(_encode_value(d_lat))
        result.append(_encode_value(d_lng))

    return "".join(result)


def _encode_value(value: int) -> str:
    """整数値をポリラインエンコード形式に変換

    Args:
        value: エンコードする整数値

    Returns:
        str: エンコードされた文字列
    """
    # 負の値の処理: 左シフトしてから反転
    value = ~(value << 1) if value < 0 else value << 1

    result: list[str] = []
    while value >= 0x20:
        result.append(chr((0x20 | (value & 0x1F)) + 63))
        value >>= 5
    result.append(chr(value + 63))

    return "".join(result)


def merge_polylines(polyline1: str, polyline2: str) -> str:
    """2つのポリラインを結合

    2つのポリラインをデコードし、座標リストを結合してから
    再エンコードします。

    Args:
        polyline1: 最初のポリライン
        polyline2: 2番目のポリライン

    Returns:
        str: 結合されたポリライン
    """
    coords1 = decode_polyline(polyline1) if polyline1 else []
    coords2 = decode_polyline(polyline2) if polyline2 else []

    # 座標リストを結合(重複する終点/始点がある場合は2番目の最初の座標を除く)
    if coords1 and coords2 and coords1[-1] == coords2[0]:
        merged = coords1 + coords2[1:]
    else:
        merged = coords1 + coords2

    return encode_polyline(merged)


def decode_polyline(polyline_str: str) -> list[Coordinate]:
    """Google Maps APIのポリラインをデコードして座標リストを生成

    Args:
        polyline_str: ポリラインの文字列

    Returns:
        list[Coordinate]: 座標リスト
    """
    index = 0
    coordinates = []
    lat = 0
    lng = 0

    while index < len(polyline_str):
        shift = 0
        result = 0
        while True:
            if index >= len(polyline_str):
                lat_float = lat * 1e-5
                lng_float = lng * 1e-5
                raise ValueError(
                    f"Invalid or incomplete polyline: input ended unexpectedly "
                    f"while decoding latitude at index {index} "
                    f"(current position: lat={lat_float:.5f}, lng={lng_float:.5f})"
                )
            byte = ord(polyline_str[index]) - 63
            index += 1
            result |= (byte & 0x1F) << shift
            shift += 5
            if byte < 0x20:
                break

        dlat = ~(result >> 1) if result & 1 else (result >> 1)
        lat += dlat

        shift = 0
        result = 0
        while True:
            if index >= len(polyline_str):
                lat_float = lat * 1e-5
                lng_float = lng * 1e-5
                raise ValueError(
                    f"Invalid or incomplete polyline: input ended unexpectedly "
                    f"while decoding longitude at index {index} "
                    f"(current position: lat={lat_float:.5f}, lng={lng_float:.5f})"
                )
            byte = ord(polyline_str[index]) - 63
            index += 1
            result |= (byte & 0x1F) << shift
            shift += 5
            if byte < 0x20:
                break

        dlng = ~(result >> 1) if result & 1 else (result >> 1)
        lng += dlng

        lat_float = lat * 1e-5
        lng_float = lng * 1e-5
        coordinates.append(Coordinate(latitude=lat_float, longitude=lng_float))

    return coordinates
