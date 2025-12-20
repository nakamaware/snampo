"""値オブジェクト定義

ドメインの値オブジェクトを定義します。
"""

from app.domain.value_objects.coordinate import Coordinate
from app.domain.value_objects.image_height import ImageHeight
from app.domain.value_objects.image_size import ImageSize
from app.domain.value_objects.image_width import ImageWidth
from app.domain.value_objects.latitude import Latitude
from app.domain.value_objects.longitude import Longitude

__all__ = [
    "Coordinate",
    "ImageHeight",
    "ImageSize",
    "ImageWidth",
    "Latitude",
    "Longitude",
]
