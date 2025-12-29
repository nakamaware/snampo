"""ポート定義

外部サービスへのインターフェースを定義します。
"""

from app.application.gateway_interfaces.google_maps_gateway import (
    GoogleMapsGateway,
    StreetViewMetadata,
)

__all__ = ["GoogleMapsGateway", "StreetViewMetadata"]
