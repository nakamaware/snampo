"""Street View画像取得ユースケース

Street View画像取得のビジネスロジックをオーケストレーションします。
"""

from injector import inject

from app.application.dto.street_view_dto import StreetViewImageResultDto
from app.application.services.street_view_service import StreetViewService
from app.domain.value_objects import Latitude, Longitude


class GetStreetViewImageUseCase:
    """Street View画像取得ユースケース"""

    @inject
    def __init__(self, street_view_service: StreetViewService) -> None:
        """初期化

        Args:
            street_view_service: Street Viewサービス
        """
        self.street_view_service = street_view_service

    def execute(self, latitude: float, longitude: float, size: str) -> StreetViewImageResultDto:
        """Street View画像を取得する

        Args:
            latitude: 緯度
            longitude: 経度
            size: 画像サイズ

        Returns:
            StreetViewImageResultDto: メタデータと画像データ
        """
        # 値オブジェクトに変換
        lat_vo = Latitude(value=latitude)
        lng_vo = Longitude(value=longitude)

        # サービス層の共通処理を呼び出し
        return self.street_view_service.get_street_view_image_data(lat_vo, lng_vo, size)
