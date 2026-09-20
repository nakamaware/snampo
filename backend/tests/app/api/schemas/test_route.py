"""Route API スキーマのテスト"""

from urllib.parse import parse_qs, urlparse

from app.api.schemas.route import MidPoint, _build_google_maps_url
from app.application.usecases.route_result_dto import RoutePointDto
from app.domain.value_objects import Coordinate, Landmark, StreetViewImage


def _street_view(coordinate: Coordinate) -> StreetViewImage:
    """テスト用の最小 Street View 画像。"""
    return StreetViewImage(
        metadata_coordinate=coordinate,
        original_coordinate=coordinate,
        image_data=b"fake-image",
        heading=90.0,
    )


def test_google_place_idはquery_place_idに載ること() -> None:
    """中間地点など Google ID はそのまま Maps の place 検索に使う。"""
    coordinate = Coordinate(latitude=35.681, longitude=139.767)
    url = _build_google_maps_url(coordinate, "ChIJXSModoWLGGARILWiCfeu2M0")
    query = parse_qs(urlparse(url).query)
    assert query["query"] == ["35.681,139.767"]
    assert query["query_place_id"] == ["ChIJXSModoWLGGARILWiCfeu2M0"]


def test_apple_place_idはquery_place_idに載せないこと() -> None:
    """Apple ID を Google Maps に渡すと地点が開けないので座標だけにする。"""
    coordinate = Coordinate(latitude=35.232, longitude=139.107)
    url = _build_google_maps_url(coordinate, "apple:I123456789")
    query = parse_qs(urlparse(url).query)
    assert query["query"] == ["35.232,139.107"]
    assert "query_place_id" not in query


def test_MidPointはapple_idの目的地でも座標URLになること() -> None:
    """ランダム目的地 (apple: place_id) の google_maps_url が壊れていない。"""
    coordinate = Coordinate(latitude=35.232, longitude=139.107)
    point = RoutePointDto(
        coordinate=coordinate,
        street_view_image=_street_view(coordinate),
        landmark=Landmark(
            place_id="apple:shrine-1",
            display_name="箱根神社",
            coordinate=coordinate,
            primary_type="religious_site",
        ),
    )
    midpoint = MidPoint.from_dto(point)
    assert midpoint.name == "箱根神社"
    assert midpoint.genre == "religious_site"
    query = parse_qs(urlparse(midpoint.google_maps_url or "").query)
    assert "query_place_id" not in query
    assert query["query"] == ["35.232,139.107"]
