"""スポット ID の生成

スポット (中間地点・目的地) を識別する ID を組み立てます。

- ランドマークがあるスポットは Places API の place_id をそのまま使う
- ランドマークがないスポット (目的地指定モードの目的地) は RFC 5870 の geo URI
  (`geo:{lat},{lng}`、小数 6 桁) を使う

place_id は英数字と `_`、`-` だけでできているため、`:` や `,` を含む geo URI とは衝突しません。
"""

from app.domain.value_objects import Coordinate, Landmark

GEO_URI_DECIMAL_PLACES = 6


def build_spot_id(coordinate: Coordinate, landmark: Landmark | None) -> str:
    """スポット ID を生成する

    Args:
        coordinate: スポットの座標 (ランドマークがない場合に使う)
        landmark: スポットに対応するランドマーク

    Returns:
        str: スポット ID
    """
    if landmark is not None:
        return landmark.place_id
    lat, lng = coordinate.to_float_tuple()
    places = GEO_URI_DECIMAL_PLACES
    return f"geo:{lat:.{places}f},{lng:.{places}f}"
