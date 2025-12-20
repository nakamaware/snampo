"""ルート生成APIエンドポイント"""

from fastapi import APIRouter, Query

from app import container
from app.api.schemas import RouteResponse
from app.application.usecases.generate_route_usecase import GenerateRouteUseCase

router = APIRouter()

# DIコンテナからUseCaseを取得
_container = container.get_container()


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
) -> RouteResponse:
    """ルートを生成

    Args:
        current_lat: 現在の緯度
        current_lng: 現在の経度
        radius: 半径 (メートル単位)

    Returns:
        RouteResponse: ルート情報
    """
    usecase = _container.get(GenerateRouteUseCase)
    dto = usecase.execute(current_lat, current_lng, radius)
    return RouteResponse.from_dto(dto)
