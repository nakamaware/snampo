"""Street View APIスキーマ定義"""

from pydantic import BaseModel

from app.application.dto.street_view_dto import StreetViewImageResultDto
from app.domain.value_objects import Latitude, Longitude


class StreetViewImageResponse(BaseModel):
    """Street View画像のメタデータと画像データを表すモデル"""

    metadata_latitude: Latitude
    metadata_longitude: Longitude
    original_latitude: Latitude
    original_longitude: Longitude
    image_data: str

    @classmethod
    def from_dto(cls, dto: StreetViewImageResultDto) -> "StreetViewImageResponse":
        """StreetViewImageResultDtoからAPIレスポンススキーマを作成

        Args:
            dto: Street View画像取得結果DTO

        Returns:
            StreetViewImageResponse: APIレスポンススキーマ
        """
        return cls(
            metadata_latitude=dto.metadata_coordinate.latitude,
            metadata_longitude=dto.metadata_coordinate.longitude,
            original_latitude=dto.original_coordinate.latitude,
            original_longitude=dto.original_coordinate.longitude,
            image_data=dto.image_data,
        )
