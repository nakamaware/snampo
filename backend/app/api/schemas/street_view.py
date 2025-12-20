"""Street View APIスキーマ定義"""

from pydantic import BaseModel

from app.application.dto.street_view_dto import StreetViewImageResultDto


class StreetViewImageResponse(BaseModel):
    """Street View画像のメタデータと画像データを表すモデル"""

    metadata_latitude: float
    metadata_longitude: float
    original_latitude: float
    original_longitude: float
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
            metadata_latitude=dto.metadata_coordinate.latitude.value,
            metadata_longitude=dto.metadata_coordinate.longitude.value,
            original_latitude=dto.original_coordinate.latitude.value,
            original_longitude=dto.original_coordinate.longitude.value,
            image_data=dto.image_data,
        )
