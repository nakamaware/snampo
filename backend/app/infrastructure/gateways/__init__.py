"""Gateway実装

外部サービスへのGateway実装を定義します。
"""

from app.infrastructure.gateways.apple_maps_gateway_impl import AppleMapsGatewayImpl
from app.infrastructure.gateways.google_maps_gateway_impl import GoogleMapsGatewayImpl

__all__ = ["AppleMapsGatewayImpl", "GoogleMapsGatewayImpl"]
