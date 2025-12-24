"""Gateway定義

外部サービスへのGateway実装を定義します。
"""

from app.adapters.gateways.google_maps_gateway_impl import GoogleMapsGatewayImpl

__all__ = ["GoogleMapsGatewayImpl"]
