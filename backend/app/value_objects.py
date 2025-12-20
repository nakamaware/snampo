"""値オブジェクト定義

ドメインの値オブジェクトを定義します。
"""

from pydantic import BaseModel, ConfigDict, field_validator, model_serializer


class Latitude(BaseModel):
    """緯度を表す値オブジェクト"""

    model_config = ConfigDict(frozen=True)  # 不変性を保証

    value: float

    @field_validator("value")
    @classmethod
    def validate_range(cls, v: float) -> float:
        """緯度の範囲を検証

        Args:
            v: 検証する緯度の値

        Returns:
            float: 検証済みの緯度の値

        Raises:
            ValueError: 緯度が-90から90の範囲外の場合
        """
        if not (-90.0 <= v <= 90.0):
            raise ValueError(f"Latitude must be between -90 and 90, got {v}")
        return v

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

    @model_serializer
    def serialize_model(self) -> float:
        """JSONシリアライズ時にfloatとして出力

        Returns:
            float: 緯度の値
        """
        return self.value


class Longitude(BaseModel):
    """経度を表す値オブジェクト"""

    model_config = ConfigDict(frozen=True)  # 不変性を保証

    value: float

    @field_validator("value")
    @classmethod
    def validate_range(cls, v: float) -> float:
        """経度の範囲を検証

        Args:
            v: 検証する経度の値

        Returns:
            float: 検証済みの経度の値

        Raises:
            ValueError: 経度が-180から180の範囲外の場合
        """
        if not (-180.0 <= v <= 180.0):
            raise ValueError(f"Longitude must be between -180 and 180, got {v}")
        return v

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

    @model_serializer
    def serialize_model(self) -> float:
        """JSONシリアライズ時にfloatとして出力

        Returns:
            float: 経度の値
        """
        return self.value
