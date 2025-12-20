"""DTO (Data Transfer Object) 定義

Application層から返されるデータ転送オブジェクトを定義します。
"""

from app.application.dto.route_dto import RouteResultDto
from app.application.dto.street_view_dto import StreetViewImageResultDto

__all__ = ["RouteResultDto", "StreetViewImageResultDto"]
