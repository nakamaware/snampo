"""アダプター層のポート定義

外部サービスクライアントへのインターフェースを定義します。
"""

from app.adapters.client_interfaces.google_maps_client_if import GoogleMapsClientIf

__all__ = ["GoogleMapsClientIf"]
