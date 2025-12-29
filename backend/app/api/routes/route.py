"""ルート生成APIのルーター"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Query

from app import container
from app.api.schemas import RouteResponse
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


@router.get("/route")
def route(
    current_lat: float = Query(
        ...,
        alias="currentLat",
        description="現在地の緯度",
        ge=-90,
        le=90,
        example=35.6762,
    ),
    current_lng: float = Query(
        ...,
        alias="currentLng",
        description="現在地の経度",
        ge=-180,
        le=180,
        example=139.6503,
    ),
    radius: float = Query(
        ...,
        description="目的地を生成する半径 (メートル単位)",
        gt=0,
        le=40075000,  # 地球の赤道一周の長さ (メートル)
        example=5000,
    ),
    # NOTE: テストしやすいようにFastAPIの依存性注入機能を使用
    usecase: GenerateRouteUseCase = Depends(get_generate_route_usecase),  # noqa: B008
) -> RouteResponse:
    """ルートを生成

    Args:
        current_lat: 現在の緯度
        current_lng: 現在の経度
        radius: 半径 (メートル単位)
        usecase: ルート生成ユースケース

    Returns:
        RouteResponse: ルート情報

    Raises:
        HTTPException: 外部サービスエラーが発生した場合、またはバリデーションエラーが発生した場合
    """
    try:
        current_coordinate = Coordinate(latitude=current_lat, longitude=current_lng)
    except ValueError as e:
        logger.error(
            f"ValueError in /route: {e}",
            extra={"current_lat": current_lat, "current_lng": current_lng, "radius": radius},
        )
        raise HTTPException(status_code=400, detail=str(e)) from e

    try:
        result = usecase.execute(current_coordinate, radius)
        return RouteResponse.from_dto(result)
    except RouteGenerationError as e:
        logger.warning(
            f"RouteGenerationError in /route: {e}",
            extra={"current_lat": current_lat, "current_lng": current_lng, "radius": radius},
        )
        raise HTTPException(status_code=422, detail=str(e)) from e
    except ExternalServiceError as e:
        logger.error(
            f"ExternalServiceError in /route: {e}",
            extra={"current_lat": current_lat, "current_lng": current_lng, "radius": radius},
        )
        raise HTTPException(status_code=500, detail=str(e)) from e
    except Exception as e:
        # NOTE: 未知のエラーはスタックトレースを含むexceptionレベルでログを出力
        logger.exception(
            f"Exception in /route: {e}",
            extra={"current_lat": current_lat, "current_lng": current_lng, "radius": radius},
        )
        raise HTTPException(status_code=500, detail=str(e)) from e
