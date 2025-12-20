"""Street View画像取得DTO定義"""

from dataclasses import dataclass

from app.domain.value_objects import Coordinate


@dataclass(frozen=True)
class StreetViewImageResultDto:
    """Street View画像取得結果DTO

    Application層から返されるStreet View画像情報を表します。

    Attributes:
        metadata_coordinate: メタデータから取得した画像の実際の座標
        original_coordinate: リクエストした元の座標
        image_data: Base64エンコードされた画像データ
    """

    metadata_coordinate: Coordinate
    original_coordinate: Coordinate
    image_data: str
