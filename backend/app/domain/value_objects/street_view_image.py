"""Street View画像値オブジェクト定義

Street View画像情報を表す値オブジェクトです。
"""

from dataclasses import dataclass

from app.domain.value_objects.coordinate import Coordinate


@dataclass(frozen=True)
class StreetViewImage:
    """Street View画像を表す値オブジェクト"""

    metadata_coordinate: Coordinate
    original_coordinate: Coordinate
    image_data: bytes
