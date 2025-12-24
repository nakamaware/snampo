"""座標値オブジェクト定義

緯度・経度のペアを表す値オブジェクトです。
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class Latitude:
    """緯度を表す値オブジェクト"""

    value: float

    def __post_init__(self) -> None:
        """緯度の範囲を検証

        Raises:
            ValueError: 緯度が-90から90の範囲外の場合
        """
        if not (-90.0 <= self.value <= 90.0):
            raise ValueError(f"Latitude must be between -90 and 90, got {self.value}")

    def to_float(self) -> float:
        """float型に変換

        Returns:
            float: 緯度の値
        """
        return self.value

    def __hash__(self) -> int:
        """ハッシュ値を計算 (lru_cacheで使用するため)

        Returns:
            int: ハッシュ値
        """
        return hash(self.value)


@dataclass(frozen=True)
class Longitude:
    """経度を表す値オブジェクト"""

    value: float

    def __post_init__(self) -> None:
        """経度の範囲を検証

        Raises:
            ValueError: 経度が-180から180の範囲外の場合
        """
        if not (-180.0 <= self.value <= 180.0):
            raise ValueError(f"Longitude must be between -180 and 180, got {self.value}")

    def to_float(self) -> float:
        """float型に変換

        Returns:
            float: 経度の値
        """
        return self.value

    def __hash__(self) -> int:
        """ハッシュ値を計算 (lru_cacheで使用するため)

        Returns:
            int: ハッシュ値
        """
        return hash(self.value)


@dataclass(frozen=True)
class Coordinate:
    """座標を表す値オブジェクト (緯度・経度のペア)"""

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
        # frozen dataclassのフィールドを設定するためにobject.__setattr__を使用
        object.__setattr__(self, "latitude", lat)
        object.__setattr__(self, "longitude", lng)

    def to_float_tuple(self) -> tuple[float, float]:
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
