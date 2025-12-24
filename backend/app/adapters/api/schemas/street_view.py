"""Street View APIスキーマ定義"""

import base64

from pydantic import BaseModel

from app.application.usecases.get_street_view_image_usecase import StreetViewImageResultDto


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
        # 画像データをBase64エンコードして文字列に変換
        image_data_base64 = base64.b64encode(dto.image_data).decode("utf-8")

        metadata_lat_float, metadata_lng_float = dto.metadata_coordinate.to_float_tuple()
        original_lat_float, original_lng_float = dto.original_coordinate.to_float_tuple()
        return cls(
            metadata_latitude=metadata_lat_float,
            metadata_longitude=metadata_lng_float,
            original_latitude=original_lat_float,
            original_longitude=original_lng_float,
            image_data=image_data_base64,
        )
