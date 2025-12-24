"""ポート定義

外部サービスへのインターフェースを定義します。
"""

from app.application.gateway_interfaces.google_maps_gateway_if import (
    GoogleMapsGatewayIf,
    StreetViewMetadata,
)

__all__ = ["GoogleMapsGatewayIf", "StreetViewMetadata"]
