"""ルート生成APIのルーター"""

import logging

from fastapi import APIRouter, Depends, HTTPException
from pydantic import ValidationError

from app import container
from app.api.schemas import (
    RouteRequest,
    RouteRequestDestination,
    RouteRequestRandom,
    RouteResponse,
)
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
        request: ルート生成リクエスト(現在地の緯度・経度、半径または目的地座標を含む)
        usecase: ルート生成ユースケース

    Returns:
        RouteResponse: ルート情報

    Raises:
        HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
    """
    try:
        current_coordinate = Coordinate(latitude=request.current_lat, longitude=request.current_lng)
        destination_coordinate = None
        radius_m = None

        match request.mode:
            case "random":
                radius_m = request.radius
            case "destination":
                destination_coordinate = Coordinate(
                    latitude=request.destination_lat, longitude=request.destination_lng
                )
            case _:
                raise HTTPException(status_code=400, detail="Invalid mode")
    except ValidationError as e:
        extra_log = _build_extra_log(request, validation_error=e)
        logger.error(f"ValidationError in /route: {e}", extra=extra_log)
        raise HTTPException(status_code=400, detail=str(e)) from e
    except Exception as e:
        extra_log = _build_extra_log(request)
        logger.exception(f"Exception in /route: {e}", extra=extra_log)
        raise HTTPException(status_code=500, detail=str(e)) from e

    try:
        result = usecase.execute(
            current_coordinate,
            radius_m=radius_m,
            destination_coordinate=destination_coordinate,
        )
        return RouteResponse.from_dto(result)
    except RouteGenerationError as e:
        extra_log = _build_extra_log(request)
        logger.warning(f"RouteGenerationError in /route: {e}", extra=extra_log)
        raise HTTPException(status_code=500, detail=str(e)) from e
    except ExternalServiceError as e:
        extra_log = _build_extra_log(request)
        logger.error(f"ExternalServiceError in /route: {e}", extra=extra_log)
        raise HTTPException(status_code=500, detail=str(e)) from e
    except Exception as e:
        # NOTE: 未知のエラーはスタックトレースを含むexceptionレベルでログを出力
        extra_log = _build_extra_log(request)
        logger.exception(f"Exception in /route: {e}", extra=extra_log)
        raise HTTPException(status_code=500, detail=str(e)) from e


def _build_extra_log(
    request: RouteRequest, validation_error: ValidationError | None = None
) -> dict:
    """ログ用のextra辞書を構築

    Args:
        request: ルート生成リクエスト
        validation_error: バリデーションエラー (存在する場合)

    Returns:
        dict: ログ用のextra辞書
    """
    extra_log: dict = {
        "current_lat": request.current_lat,
        "current_lng": request.current_lng,
    }

    if isinstance(request, RouteRequestRandom):
        extra_log["radius"] = request.radius
    elif isinstance(request, RouteRequestDestination):
        extra_log["destination_lat"] = request.destination_lat
        extra_log["destination_lng"] = request.destination_lng

    if validation_error is not None:
        extra_log["errors"] = str(validation_error.errors())
        extra_log["body"] = validation_error.json()

    return extra_log
