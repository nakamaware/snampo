"""Street View APIエンドポイント"""

from fastapi import APIRouter, Query

from app import container
from app.api.schemas import StreetViewImageResponse
from app.application.usecases.get_street_view_image_usecase import GetStreetViewImageUseCase

router = APIRouter()

# DIコンテナからUseCaseを取得
_container = container.get_container()


@router.get("/streetview")
def get_street_view_image(
    latitude: float = Query(
        ...,
        description="緯度",
        ge=-90,
        le=90,
        example=35.6762,
    ),
    longitude: float = Query(
        ...,
        description="経度",
        ge=-180,
        le=180,
        example=139.6503,
    ),
    size: str = Query(
        default="600x300",
        description="画像サイズ",
        example="600x300",
    ),
) -> StreetViewImageResponse:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        StreetViewImageResponse: メタデータと画像データ
    """
    usecase = _container.get(GetStreetViewImageUseCase)
    dto = usecase.execute(latitude, longitude, size)
    return StreetViewImageResponse.from_dto(dto)
