"""Street View画像取得ユースケース

Street View画像取得のビジネスロジックをオーケストレーションします。
"""

from dataclasses import dataclass

from injector import inject

from app.application.services.street_view_service import StreetViewService
from app.domain.value_objects import Coordinate, ImageSize


@dataclass(frozen=True)
class StreetViewImageResultDto:
    """Street View画像取得結果DTO

    Application層から返されるStreet View画像情報を表します。

    Attributes:
        metadata_coordinate: メタデータから取得した画像の実際の座標
        original_coordinate: リクエストした元の座標
        image_data: 画像データ (バイナリ)
    """

    metadata_coordinate: Coordinate
    original_coordinate: Coordinate
    image_data: bytes


class GetStreetViewImageUseCase:
    """Street View画像取得ユースケース"""

    @inject
    def __init__(self, street_view_service: StreetViewService) -> None:
        """初期化

        Args:
            street_view_service: Street Viewサービス
        """
        self.street_view_service = street_view_service

    def execute(self, coordinate: Coordinate, image_size: ImageSize) -> StreetViewImageResultDto:
        """Street View画像を取得する

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            StreetViewImageResultDto: メタデータと画像データ

        Raises:
            ExternalServiceError: 外部サービスエラーが発生した場合
        """
        street_view_image = self.street_view_service.get_street_view_image_data(
            coordinate, image_size
        )

        return StreetViewImageResultDto(
            metadata_coordinate=street_view_image.metadata_coordinate,
            original_coordinate=street_view_image.original_coordinate,
            image_data=street_view_image.image_data,
        )
