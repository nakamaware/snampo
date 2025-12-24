"""ドメイン例外定義

ドメイン層で使用する例外を定義します。
"""

from app.domain.exceptions.external_service import (
    ExternalServiceError,
    ExternalServiceTimeoutError,
    ExternalServiceValidationError,
)
from app.domain.exceptions.route import RouteGenerationError

__all__ = [
    "ExternalServiceError",
    "ExternalServiceTimeoutError",
    "ExternalServiceValidationError",
    "RouteGenerationError",
]
