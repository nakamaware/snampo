"""OpenAPIスキーマカスタマイズ

OpenAPIスキーマのカスタマイズ処理を定義します。
"""

from fastapi import FastAPI


def custom_openapi(app: FastAPI) -> dict:
    """OpenAPIスキーマをカスタマイズして返す

    Args:
        app: FastAPIアプリケーションインスタンス

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
