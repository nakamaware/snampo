"""Street View画像取得サービス

Street View画像取得の共通処理を提供します。
"""

import base64
import logging

from fastapi import HTTPException
from injector import inject

from app.application.dto.street_view_dto import StreetViewImageResultDto
from app.application.ports.google_maps_gateway import GoogleMapsGateway
from app.domain.value_objects import Coordinate, Latitude, Longitude

logger = logging.getLogger(__name__)


class StreetViewService:
    """Street View画像取得サービス"""

    @inject
    def __init__(self, google_maps_gateway: GoogleMapsGateway) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
        """
        self.google_maps_gateway = google_maps_gateway

    def get_street_view_image_data(
        self, latitude: Latitude, longitude: Longitude, size: str
    ) -> StreetViewImageResultDto:
        """Street View Image Metadata APIを使用して画像のメタデータを取得

        Args:
            latitude: 緯度(値オブジェクト)
            longitude: 経度(値オブジェクト)
            size: 画像サイズ

        Returns:
            StreetViewImageResult: メタデータと画像データ

        Raises:
            HTTPException: Street View画像が取得できない場合
        """
        # メタデータの取得(キャッシュ付き)
        metadata = self.google_maps_gateway.get_street_view_metadata(latitude, longitude)

        if metadata["status"] == "OK":
            # メタデータから画像の実際の位置情報を取得
            metadata_latitude = Latitude(value=metadata["location"]["lat"])
            metadata_longitude = Longitude(value=metadata["location"]["lng"])
            logger.info(
                f"Actual Image Location: Latitude {metadata_latitude.to_float()}, "
                f"Longitude {metadata_longitude.to_float()}"
            )
        else:
            # ステータスが'OK'でない場合のエラーハンドリング
            logger.error(
                "Street View metadata API returned a non-OK status for a requested location."
            )
            raise HTTPException(
                status_code=400, detail=f"Street View metadata unavailable: {metadata['status']}."
            )

        # Street View Static APIから画像を取得(キャッシュ付き)
        image_content = self.google_maps_gateway.get_street_view_image(latitude, longitude, size)

        # 画像データをBase64エンコードして文字列に変換
        image_data = base64.b64encode(image_content).decode("utf-8")

        # StreetViewImageResultインスタンスを返す
        return StreetViewImageResultDto(
            metadata_coordinate=Coordinate(
                latitude=metadata_latitude, longitude=metadata_longitude
            ),
            original_coordinate=Coordinate(latitude=latitude, longitude=longitude),
            image_data=image_data,
        )
