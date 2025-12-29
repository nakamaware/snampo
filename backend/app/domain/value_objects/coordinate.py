"""座標値オブジェクト定義

緯度・経度のペアを表す値オブジェクトです。
"""

from pydantic import BaseModel, ConfigDict, Field


class Coordinate(BaseModel):
    """座標を表す値オブジェクト (緯度・経度のペア)"""

    model_config = ConfigDict(frozen=True)

    latitude: float = Field(
        ge=-90.0,
        le=90.0,
        description="緯度の値 (-90から90の範囲)",
    )

    longitude: float = Field(
        ge=-180.0,
        le=180.0,
        description="経度の値 (-180から180の範囲)",
    )

    def __hash__(self) -> int:
        """ハッシュ値を計算

        Returns:
            int: ハッシュ値
        """
        return hash((self.latitude, self.longitude))

    def to_float_tuple(self) -> tuple[float, float]:
        """floatのタプルに変換

        Returns:
            tuple[float, float]: (緯度, 経度)のタプル
        """
        return (self.latitude, self.longitude)
