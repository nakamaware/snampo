"""FastAPIのエントリーポイント"""

import logging

from fastapi import FastAPI

from app.api.openapi import custom_openapi
from app.api.routes import route

logger = logging.getLogger(__name__)
app = FastAPI()

# OpenAPIスキーマをカスタマイズ
# TODO: できれば削除したい
# NOTE: ラムダでラップしないと即座に実行されて呼び出し不可になる
app.openapi = lambda: custom_openapi(app)

app.include_router(route.router)
