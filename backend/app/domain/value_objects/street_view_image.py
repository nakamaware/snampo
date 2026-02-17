"""Street View画像値オブジェクト定義

Street View画像情報を表す値オブジェクトです。
"""

from pydantic import BaseModel, ConfigDict

from app.domain.value_objects.coordinate import Coordinate


class StreetViewImage(BaseModel):
    """Street View画像を表す値オブジェクト"""

    model_config = ConfigDict(frozen=True)

    metadata_coordinate: Coordinate
    original_coordinate: Coordinate
    image_data: bytes
    heading: float | None = None

    def __hash__(self) -> int:
        """ハッシュ値を計算

        Returns:
            int: ハッシュ値
        """
        return hash(
            (self.metadata_coordinate, self.original_coordinate, self.image_data, self.heading)
        )
