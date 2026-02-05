"""Street View 画像取得サービス

Street View 画像の取得に関するアプリケーションロジックを提供します。
"""

import logging

from injector import inject

from app.application.gateway_interfaces.google_maps_gateway import GoogleMapsGateway
from app.domain.exceptions import (
    ExternalServiceError,
    ExternalServiceTimeoutError,
    ExternalServiceValidationError,
)
from app.domain.value_objects import Coordinate, ImageSize, StreetViewImage

logger = logging.getLogger(__name__)


class StreetViewImageFetchService:
    """Street View 画像取得サービス

    Street View 画像の取得とメタデータの検証を行います。
    """

    @inject
    def __init__(self, gateway: GoogleMapsGateway) -> None:
        """初期化

        Args:
            gateway: Google Maps Gateway
        """
        self._gateway = gateway
        self._default_image_size = ImageSize(width=600, height=300)

    def get_image(
        self, coordinate: Coordinate, image_size: ImageSize | None = None
    ) -> StreetViewImage:
        """Street View Image Metadata APIを使用して画像のメタデータを取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ (Noneの場合はデフォルトサイズを使用)

        Returns:
            StreetViewImage: Street View画像情報

        Raises:
            ExternalServiceValidationError: Street View画像が取得できない場合
            ExternalServiceTimeoutError: Street View画像の取得がタイムアウトした場合
            ExternalServiceError: 外部サービスエラーが発生した場合
        """
        if image_size is None:
            image_size = self._default_image_size

        # ランドマークの座標だと屋内の画像が取得される可能性があるため、近くの道路上の座標を取得する
        # NOTE: ただし道路の真下に地下道があると、地下道が出てしまうケースが多い
        target_coordinate = self._get_nearest_road_coordinate(coordinate)

        # 対象座標にストリートビューが存在するかを確認するためにメタデータを取得
        try:
            metadata = self._gateway.get_street_view_metadata(target_coordinate)
        except ExternalServiceValidationError as e:
            logger.error(f"Street View metadata validation failed: {e}")
            raise ExternalServiceValidationError(str(e), service_name="Street View API") from e

        if metadata.status != "OK":
            logger.error(
                f"Street View metadata API returned a non-OK status for a requested location. "
                f"Status: {metadata.status}"
            )
            raise ExternalServiceValidationError(
                f"Street View metadata unavailable: {metadata.status}.",
                service_name="Street View API",
            )

        metadata_coordinate = metadata.location
        if metadata_coordinate is None:
            # NOTE: このケースは通常発生しない (Gateway実装のバリデーションで防がれる)
            logger.error("Street View metadata has OK status but location is None")
            raise ExternalServiceValidationError(
                "Street View metadata incomplete: location is None",
                service_name="Street View API",
            )

        # ストリートビュー画像を取得
        try:
            image_content = self._gateway.get_street_view_image(
                coordinate=metadata_coordinate,
                image_size=image_size,
            )
        except ExternalServiceTimeoutError as e:
            logger.error(f"Street View image timeout: {e}")
            raise ExternalServiceTimeoutError(str(e), service_name="Street View API") from e
        except ExternalServiceError as e:
            logger.error(f"Street View image error: {e}")
            raise ExternalServiceError(str(e), service_name="Street View API") from e

        return StreetViewImage(
            metadata_coordinate=metadata_coordinate,
            original_coordinate=coordinate,
            image_data=image_content,
        )

    def _get_nearest_road_coordinate(self, coordinate: Coordinate) -> Coordinate:
        """座標の近くにある道路上の座標を取得する

        Args:
            coordinate: 対象座標

        Returns:
            Coordinate: 最寄りの道路上の座標、または元の座標 (道路が見つからない場合は元の座標)

        Raises:
            ExternalServiceError: Roads API呼び出しエラーが発生した場合
            ExternalServiceTimeoutError: Roads API呼び出しがタイムアウトした場合
        """
        try:
            snapped_coordinate = self._gateway.snap_to_road(coordinate)
            if snapped_coordinate is not None:
                logger.info(
                    f"Using nearest road coordinate {snapped_coordinate} "
                    f"for Street View (original: {coordinate})"
                )
                return snapped_coordinate

            logger.info(
                f"No road found near {coordinate}, using original coordinate for Street View"
            )
            return coordinate
        except (ExternalServiceError, ExternalServiceTimeoutError) as e:
            logger.error(f"Roads API error while getting nearest road coordinate: {e}")
            raise
