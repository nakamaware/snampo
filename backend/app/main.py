"""FastAPIのエントリーポイント"""

import functools
import logging

from fastapi import FastAPI

from app.api.openapi import custom_openapi
from app.api.routes import route

logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)
app = FastAPI()

app.openapi = functools.partial(custom_openapi, app)

app.include_router(route.router)
