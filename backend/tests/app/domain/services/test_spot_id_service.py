"""spot_id_serviceのテスト"""

from app.domain.services.spot_id_service import build_spot_id
from app.domain.value_objects import Coordinate, Landmark


def _landmark(place_id: str) -> Landmark:
    return Landmark(
        place_id=place_id,
        display_name="東京駅",
        coordinate=Coordinate(latitude=35.681236, longitude=139.767125),
    )


def test_build_spot_id_ランドマークがある場合はplace_idをそのまま返すこと() -> None:
    """ランドマークがあるスポットは place_id がスポット ID になることを確認"""
    spot_id = build_spot_id(
        coordinate=Coordinate(latitude=35.0, longitude=139.0),
        landmark=_landmark("ChIJC3Cf2PuLGGAROO00ukl8JwA"),
    )

    assert spot_id == "ChIJC3Cf2PuLGGAROO00ukl8JwA"


def test_build_spot_id_ランドマークがない場合はgeo_URIを返すこと() -> None:
    """ランドマークがないスポットは geo:{lat},{lng} になることを確認"""
    spot_id = build_spot_id(
        coordinate=Coordinate(latitude=35.681236, longitude=139.767125),
        landmark=None,
    )

    assert spot_id == "geo:35.681236,139.767125"


def test_build_spot_id_緯度経度を小数6桁に丸めること() -> None:
    """緯度経度は小数 6 桁に丸めて固定桁で出力することを確認"""
    spot_id = build_spot_id(
        coordinate=Coordinate(latitude=35.6812364999, longitude=-139.5),
        landmark=None,
    )

    assert spot_id == "geo:35.681236,-139.500000"
