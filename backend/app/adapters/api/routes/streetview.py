"""Street View APIのルーター"""

import logging

from fastapi import APIRouter, Depends, HTTPException, Query

from app import container
from app.adapters.api.schemas import StreetViewImageResponse
from app.application.usecases.get_street_view_image_usecase import GetStreetViewImageUseCase
from app.domain.exceptions import ExternalServiceError
from app.domain.value_objects import (
    Coordinate,
    ImageHeight,
    ImageSize,
    ImageWidth,
)

logger = logging.getLogger(__name__)

router = APIRouter()


def get_street_view_image_usecase() -> GetStreetViewImageUseCase:
    """GetStreetViewImageUseCaseのインスタンスを取得

    Returns:
        GetStreetViewImageUseCase: Street View画像取得ユースケース
    """
    _container = container.get_container()
    return _container.get(GetStreetViewImageUseCase)


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
    # NOTE: テストしやすいようにFastAPIの依存性注入機能を使用
    usecase: GetStreetViewImageUseCase = Depends(get_street_view_image_usecase),  # noqa: B008
) -> StreetViewImageResponse:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ
        usecase: Street View画像取得ユースケース

    Returns:
        StreetViewImageResponse: メタデータと画像データ

    Raises:
        HTTPException: 外部サービスエラーまたはStreet View画像が見つからない場合、
            またはバリデーションエラーが発生した場合
    """
    try:
        width_str, height_str = size.split("x")
        width = int(width_str)
        height = int(height_str)
        coordinate = Coordinate(latitude=latitude, longitude=longitude)
        image_size = ImageSize(
            width=ImageWidth(value=width),
            height=ImageHeight(value=height),
        )
    except ValueError as e:
        logger.error(
            f"ValueError in /streetview: {e}",
            extra={"latitude": latitude, "longitude": longitude, "size": size},
        )
        raise HTTPException(status_code=400, detail=str(e)) from e

    try:
        result = usecase.execute(coordinate, image_size)
        return StreetViewImageResponse.from_dto(result)
    except ExternalServiceError as e:
        logger.error(
            f"ExternalServiceError in /streetview: {e}",
            extra={"latitude": latitude, "longitude": longitude, "size": size},
        )
        raise HTTPException(status_code=500, detail=str(e)) from e
    except Exception as e:
        # NOTE: 未知のエラーはスタックトレースを含むexceptionレベルでログを出力
        logger.exception(
            f"Exception in /streetview: {e}",
            extra={"latitude": latitude, "longitude": longitude, "size": size},
        )
        raise HTTPException(status_code=500, detail=str(e)) from e
