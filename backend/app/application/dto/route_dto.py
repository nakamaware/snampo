"""ルート生成DTO定義"""

from dataclasses import dataclass

from app.domain.value_objects import Coordinate


@dataclass(frozen=True)
class RouteResultDto:
    """ルート生成結果DTO

    Application層から返されるルート情報を表します。

    Attributes:
        departure: 出発地点の座標
        destination: 目的地の座標
        midpoints: 中間地点の座標リスト
        overview_polyline: ルートの概要ポリライン文字列
        midpoint_images: 中間地点の画像情報 (座標 -> (画像座標, 画像データ))
        destination_image: 目的地の画像情報 (画像座標, 画像データ)
    """

    departure: Coordinate
    destination: Coordinate
    midpoints: list[Coordinate]
    overview_polyline: str
    midpoint_images: dict[Coordinate, tuple[Coordinate, str]]
    destination_image: tuple[Coordinate, str] | None = None
