"""FastAPIのエントリーポイント"""

import logging

from fastapi import FastAPI

from app.adapters.api.openapi import custom_openapi
from app.adapters.api.routes import route, streetview

logger = logging.getLogger(__name__)
app = FastAPI()

# OpenAPIスキーマをカスタマイズ
# TODO: できれば削除したい
# NOTE: ラムダでラップしないと即座に実行されて呼び出し不可になる
app.openapi = lambda: custom_openapi(app)

app.include_router(route.router)
app.include_router(streetview.router)
