"""Street View画像取得サービス

Street View画像取得の共通処理を提供します。
"""

import logging

from injector import inject

from app.application.gateway_interfaces.google_maps_gateway_if import GoogleMapsGatewayIf
from app.domain.exceptions import ExternalServiceValidationError
from app.domain.value_objects import Coordinate, ImageSize, StreetViewImage

logger = logging.getLogger(__name__)


class StreetViewService:
    """Street View画像取得サービス"""

    @inject
    def __init__(self, google_maps_gateway: GoogleMapsGatewayIf) -> None:
        """初期化

        Args:
            google_maps_gateway: Google Maps Gateway
        """
        self.google_maps_gateway = google_maps_gateway

    def get_street_view_image_data(
        self, coordinate: Coordinate, image_size: ImageSize
    ) -> StreetViewImage:
        """Street View Image Metadata APIを使用して画像のメタデータを取得

        Args:
            coordinate: 座標
            image_size: 画像サイズ

        Returns:
            StreetViewImage: Street View画像情報

        Raises:
            ExternalServiceValidationError: Street View画像が取得できない場合
        """
        metadata_coordinate = self._get_validated_metadata(coordinate)
        image_content = self.google_maps_gateway.get_street_view_image(
            coordinate=metadata_coordinate,
            image_size=image_size,
        )
        return StreetViewImage(
            metadata_coordinate=metadata_coordinate,
            original_coordinate=coordinate,
            image_data=image_content,
        )

    def _get_validated_metadata(self, coordinate: Coordinate) -> Coordinate:
        """メタデータを取得し、検証する

        Args:
            coordinate: 座標

        Returns:
            Coordinate: メタデータから取得した画像の実際の座標

        Raises:
            ExternalServiceValidationError: Street View画像が取得できない場合
        """
        try:
            metadata = self.google_maps_gateway.get_street_view_metadata(coordinate)
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

        location_coordinate = metadata.location
        if location_coordinate is None:
            # このケースは通常発生しない(Gateway実装のバリデーションで防がれる)
            logger.error("Street View metadata has OK status but location is None")
            raise ExternalServiceValidationError(
                "Street View metadata incomplete: location is None",
                service_name="Street View API",
            )

        logger.info(
            f"Actual Image Location: Latitude {location_coordinate.latitude.to_float()}, "
            f"Longitude {location_coordinate.longitude.to_float()}"
        )

        return location_coordinate
