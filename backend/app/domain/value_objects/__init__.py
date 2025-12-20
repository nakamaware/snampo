"""値オブジェクト定義

ドメインの値オブジェクトを定義します。
"""

from app.domain.value_objects.coordinate import Coordinate
from app.domain.value_objects.latitude import Latitude
from app.domain.value_objects.longitude import Longitude

__all__ = ["Coordinate", "Latitude", "Longitude"]
