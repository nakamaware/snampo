import logging

from fastapi import FastAPI, Query

from app.models import RouteRequest, RouteResponse, StreetViewImageResponse
from app.services.route_service import generate_route, get_street_view_image_data

# Configure logging
logger = logging.getLogger(__name__)

app = FastAPI()

print("Hello, World!")


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
def get_street_view_image(
    latitude: float = Query(
        ...,
        description="緯度",
        ge=-90,
        le=90,
        example=35.6762,
    ),
    longitude: float = Query(
        ...,
        description="経度",
        ge=-180,
        le=180,
        example=139.6503,
    ),
    size: str = Query(
        default="600x300",
        description="画像サイズ",
        example="600x300",
    ),
) -> StreetViewImageResponse:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        StreetViewImageResponse: メタデータと画像データ
    """
    return get_street_view_image_data(latitude, longitude, size)


@app.post("/route")
def route(request: RouteRequest) -> RouteResponse:
    """ルートを生成

    Args:
        request: ルート生成リクエスト(現在地の緯度・経度、半径を含む)

    Returns:
        RouteResponse: ルート情報
    """
    return generate_route(request.current_lat, request.current_lng, request.radius)
