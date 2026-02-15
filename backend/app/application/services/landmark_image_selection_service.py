"""画像付きランドマーク選択サービス

画像が取得可能なランドマークを選択するロジックを提供します。
"""

import logging
import random

from injector import inject

from app.application.services.street_view_image_fetch_service import StreetViewImageFetchService
from app.domain.exceptions import ExternalServiceValidationError
from app.domain.value_objects import ImageSize, Landmark, StreetViewImage

logger = logging.getLogger(__name__)


class LandmarkImageSelectionService:
    """画像付きランドマーク選択サービス

    候補ランドマークから画像が取得可能なものを選択します。
    """

    @inject
    def __init__(self, street_view_service: StreetViewImageFetchService) -> None:
        """初期化

        Args:
            street_view_service: Street View 画像取得サービス
        """
        self._street_view_service = street_view_service

    def select(
        self,
        candidates: list[Landmark],
        image_size: ImageSize | None = None,
        shuffle: bool = False,
    ) -> tuple[Landmark, StreetViewImage]:
        """画像が取得できるランドマークを選択する

        候補リストを順番に試行し、画像が取得できたランドマークを返す。

        Args:
            candidates: ランドマーク候補リスト
            image_size: 画像サイズ (Noneの場合はデフォルトサイズを使用)
            shuffle: Trueの場合、候補リストをランダムにシャッフルしてから選択

        Returns:
            (ランドマーク, 画像) のタプル

        Raises:
            ExternalServiceValidationError: すべての候補で画像取得に失敗した場合
        """
        if not candidates:
            raise ExternalServiceValidationError(
                "画像を取得できませんでした",
                service_name="Street View API",
            )

        # シャッフルが必要な場合は非破壊的にランダムな順序を取得
        candidates_to_use = random.sample(candidates, len(candidates)) if shuffle else candidates

        for idx, candidate in enumerate(candidates_to_use):
            try:
                image = self._street_view_service.get_image(
                    candidate.coordinate,
                    image_size,
                )
                logger.info(f"Successfully selected landmark: {candidate}")
                return candidate, image
            except ExternalServiceValidationError:
                logger.warning(
                    f"Failed to fetch image for candidate {idx + 1}/{len(candidates_to_use)} "
                    f"(place_id: {candidate.place_id}), trying next candidate"
                )
                continue

        raise ExternalServiceValidationError(
            "画像を取得できませんでした",
            service_name="Street View API",
        )
