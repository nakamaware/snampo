"""座標値オブジェクト定義

緯度・経度のペアを表す値オブジェクトです。
"""

from pydantic import BaseModel, ConfigDict

from app.domain.value_objects.latitude import Latitude
from app.domain.value_objects.longitude import Longitude


class Coordinate(BaseModel):
    """座標を表す値オブジェクト (緯度・経度のペア)"""

    model_config = ConfigDict(frozen=True)  # 不変性を保証

    latitude: Latitude
    longitude: Longitude

    def __init__(self, latitude: float | Latitude, longitude: float | Longitude) -> None:
        """座標を初期化

        Args:
            latitude: 緯度 (floatまたはLatitude値オブジェクト)
            longitude: 経度 (floatまたはLongitude値オブジェクト)
        """
        lat = latitude if isinstance(latitude, Latitude) else Latitude(value=latitude)
        lng = longitude if isinstance(longitude, Longitude) else Longitude(value=longitude)
        super().__init__(latitude=lat, longitude=lng)

    def to_tuple(self) -> tuple[float, float]:
        """floatのタプルに変換

        Returns:
            tuple[float, float]: (緯度, 経度)のタプル
        """
        return (self.latitude.to_float(), self.longitude.to_float())

    def __hash__(self) -> int:
        """ハッシュ値を計算 (lru_cacheで使用するため)

        Returns:
            int: ハッシュ値
        """
        return hash((self.latitude.value, self.longitude.value))

    def __eq__(self, other: object) -> bool:
        """等価性を判定

        Args:
            other: 比較対象のオブジェクト

        Returns:
            bool: 等しい場合True
        """
        if not isinstance(other, Coordinate):
            return False
        return (
            self.latitude.value == other.latitude.value
            and self.longitude.value == other.longitude.value
        )
