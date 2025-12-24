"""DIコンテナ設定

依存性注入の設定を行います。
Infrastructure層の実装への依存は、この設定モジュールに集約されます。
"""

from injector import Injector

from app.adapters.client_interfaces.google_maps_client_if import GoogleMapsClientIf
from app.adapters.gateways.google_maps_gateway_impl import GoogleMapsGatewayImpl
from app.application.gateway_interfaces.google_maps_gateway_if import GoogleMapsGatewayIf
from app.infrastructure.clients.google_maps_client_impl import GoogleMapsClientImpl


def create_container() -> Injector:
    """DIコンテナを作成

    Returns:
        Injector: 設定済みのDIコンテナ
    """
    injector = Injector()
    injector.binder.bind(GoogleMapsClientIf, to=GoogleMapsClientImpl)
    injector.binder.bind(GoogleMapsGatewayIf, to=GoogleMapsGatewayImpl)
    return injector


# シングルトンインスタンス
_container: Injector | None = None


def get_container() -> Injector:
    """DIコンテナのシングルトンインスタンスを取得

    Returns:
        Injector: DIコンテナインスタンス
    """
    global _container
    if _container is None:
        _container = create_container()
    return _container
