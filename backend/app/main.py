"""FastAPIのエントリーポイント"""

import functools
import logging

from fastapi import FastAPI

from app.config import ENV
from app.api.openapi import custom_openapi
from app.api.routes import route


LOG_LEVEL = logging.INFO if ENV == "prod" else logging.DEBUG
logging.basicConfig(level=LOG_LEVEL)

logger = logging.getLogger(__name__)
app = FastAPI()

# OpenAPIスキーマをカスタマイズ
# NOTE: functools.partial でラップして呼び出し時に app を渡す
app.openapi = functools.partial(custom_openapi, app)

app.include_router(route.router)
