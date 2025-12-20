"""Street View APIエンドポイント"""

from fastapi import APIRouter, HTTPException, Query

from app import container
from app.api.schemas import StreetViewImageResponse
from app.application.usecases.get_street_view_image_usecase import GetStreetViewImageUseCase
from app.domain.value_objects import ImageHeight, ImageSize, ImageWidth

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
        pattern=r"^\d+x\d+$",
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
    # sizeパラメータをパースしてValue Objectを作成
    try:
        width_str, height_str = size.split("x")
        width = int(width_str)
        height = int(height_str)
    except ValueError:
        raise HTTPException(
            status_code=400,
            detail="sizeパラメータは'WIDTHxHEIGHT'形式である必要があります(例: 600x300)",
        ) from None

    # Value Objectを作成(バリデーションはValue Object内で行われる)
    try:
        image_size = ImageSize(
            width=ImageWidth(value=width),
            height=ImageHeight(value=height),
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e)) from e

    usecase = _container.get(GetStreetViewImageUseCase)
    dto = usecase.execute(latitude, longitude, image_size)
    return StreetViewImageResponse.from_dto(dto)
