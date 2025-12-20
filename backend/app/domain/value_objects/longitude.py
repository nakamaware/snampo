"""経度値オブジェクト定義"""

from dataclasses import dataclass


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
