"""ルート生成APIのルーター"""

import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import ValidationError

from app import container
from app.api.schemas import RouteRequest, RouteResponse
from app.application.usecases.generate_route_usecase import GenerateRouteUseCase
from app.domain.exceptions import ExternalServiceError, RouteGenerationError
from app.domain.value_objects import Coordinate

logger = logging.getLogger(__name__)

router = APIRouter()


def get_generate_route_usecase() -> GenerateRouteUseCase:
    """GenerateRouteUseCaseのインスタンスを取得

    Returns:
        GenerateRouteUseCase: ルート生成ユースケース
    """
    container_instance = container.get_container()
    return container_instance.get(GenerateRouteUseCase)


@router.post("/route")
def route(
    request: RouteRequest,
    # NOTE: テストしやすいようにFastAPIの依存性注入機能を使用
    usecase: GenerateRouteUseCase = Depends(get_generate_route_usecase),  # noqa: B008
) -> RouteResponse:
    """ルートを生成

    Args:
        request: ルート生成リクエスト(現在地の緯度・経度、半径を含む)
        usecase: ルート生成ユースケース

    Returns:
        RouteResponse: ルート情報

    Raises:
        HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
    """
    try:
        current_coordinate = Coordinate(latitude=request.current_lat, longitude=request.current_lng)
    except ValidationError as e:
        logger.error(
            f"ValidationError in /route: {e}",
            extra={
                "current_lat": request.current_lat,
                "current_lng": request.current_lng,
                "radius": request.radius,
                "errors": str(e.errors()),
                "body": e.json(),
            },
        )
        raise HTTPException(status_code=400, detail=str(e)) from e
    except Exception as e:
        logger.exception(
            f"Exception in /route: {e}",
            extra={
                "current_lat": request.current_lat,
                "current_lng": request.current_lng,
                "radius": request.radius,
            },
        )
        raise HTTPException(status_code=500, detail=str(e)) from e

    try:
        result = usecase.execute(current_coordinate, request.radius)
        return RouteResponse.from_dto(result)
    except RouteGenerationError as e:
        logger.warning(
            f"RouteGenerationError in /route: {e}",
            extra={
                "current_lat": request.current_lat,
                "current_lng": request.current_lng,
                "radius": request.radius,
            },
        )
        raise HTTPException(status_code=422, detail=str(e)) from e
    except ExternalServiceError as e:
        logger.error(
            f"ExternalServiceError in /route: {e}",
            extra={
                "current_lat": request.current_lat,
                "current_lng": request.current_lng,
                "radius": request.radius,
            },
        )
        raise HTTPException(status_code=500, detail=str(e)) from e
    except Exception as e:
        # NOTE: 未知のエラーはスタックトレースを含むexceptionレベルでログを出力
        logger.exception(
            f"Exception in /route: {e}",
            extra={
                "current_lat": request.current_lat,
                "current_lng": request.current_lng,
                "radius": request.radius,
            },
        )
        raise HTTPException(status_code=500, detail=str(e)) from e
