import logging

from fastapi import FastAPI, Query

from app.models import RouteResponse
from app.services.route_service import generate_route, get_street_view_image_data

# Configure logging
logger = logging.getLogger(__name__)

app = FastAPI()


# TODO: 消したい
# OpenAPIスキーマをカスタマイズして、カスタムValidationErrorモデルを使用
def custom_openapi() -> dict:
    """OpenAPIスキーマをカスタマイズして返す

    Returns:
        dict: カスタマイズされたOpenAPIスキーマ
    """
    if app.openapi_schema:
        return app.openapi_schema
    from fastapi.openapi.utils import get_openapi

    openapi_schema = get_openapi(
        title=app.title,
        version=app.version,
        description=app.description,
        routes=app.routes,
    )
    # カスタムValidationErrorモデルのスキーマを設定(locをlist[str]として定義)
    openapi_schema["components"]["schemas"]["ValidationError"] = {
        "properties": {
            "loc": {
                "items": {"type": "string"},
                "type": "array",
                "title": "Location",
            },
            "msg": {"type": "string", "title": "Message"},
            "type": {"type": "string", "title": "Error Type"},
        },
        "type": "object",
        "required": ["loc", "msg", "type"],
        "title": "ValidationError",
    }
    app.openapi_schema = openapi_schema
    return app.openapi_schema


app.openapi = custom_openapi


@app.get("/streetview")
def get_street_view_image(latitude: float, longitude: float, size: str | None = "600x300") -> dict:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        dict: メタデータ
    """
    return get_street_view_image_data(latitude, longitude, size)


@app.get("/route")
def route(
    current_lat: str = Query(alias="currentLat"),
    current_lng: str = Query(alias="currentLng"),
    radius: str = Query(),
) -> RouteResponse:
    """ルートを生成

    Args:
        current_lat: 現在の緯度
        current_lng: 現在の経度
        radius: 半径

    Returns:
        RouteResponse: ルート情報
    """
    return generate_route(current_lat, current_lng, radius)
