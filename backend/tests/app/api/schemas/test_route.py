"""ルートAPIスキーマのテスト"""

from app.api.schemas.route import MidPoint
from app.application.usecases.route_result_dto import RoutePointDto
from app.domain.value_objects import Coordinate, Landmark, StreetViewImage


def _point(landmark: Landmark | None) -> RoutePointDto:
    coordinate = Coordinate(latitude=35.681236, longitude=139.767125)
    return RoutePointDto(
        coordinate=coordinate,
        street_view_image=StreetViewImage(
            metadata_coordinate=coordinate,
            original_coordinate=coordinate,
            image_data=b"fake image data",
        ),
        landmark=landmark,
    )


def test_from_dto_ランドマークがある地点はplace_idをspot_idにすること() -> None:
    """ランドマークがある地点の spot_id が place_id になることを確認"""
    landmark = Landmark(
        place_id="ChIJC3Cf2PuLGGAROO00ukl8JwA",
        display_name="東京駅",
        coordinate=Coordinate(latitude=35.681236, longitude=139.767125),
    )

    mid_point = MidPoint.from_dto(_point(landmark))

    assert mid_point.spot_id == "ChIJC3Cf2PuLGGAROO00ukl8JwA"


def test_from_dto_ランドマークがない地点はgeo_URIをspot_idにすること() -> None:
    """ランドマークがない地点 (目的地指定モードの目的地) の spot_id が geo URI になることを確認"""
    mid_point = MidPoint.from_dto(_point(None))

    assert mid_point.spot_id == "geo:35.681236,139.767125"
