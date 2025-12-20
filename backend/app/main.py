"""FastAPIアプリケーションエントリーポイント"""

import logging

from fastapi import FastAPI

from app.api.openapi import custom_openapi
from app.api.routes import route, streetview

# Configure logging
logger = logging.getLogger(__name__)

app = FastAPI()

# OpenAPIスキーマをカスタマイズ
app.openapi = lambda: custom_openapi(app)

# ルーターを登録
app.include_router(route.router)
app.include_router(streetview.router)
