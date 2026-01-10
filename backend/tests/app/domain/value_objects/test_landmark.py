"""landmarkのテスト"""

import pytest
from pydantic_core import ValidationError

from app.domain.value_objects.coordinate import Coordinate
from app.domain.value_objects.landmark import Landmark


def test_必須フィールドのみで作成できること() -> None:
    """必須フィールドのみでLandmarkを作成できることを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    landmark = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
    )

    assert landmark.place_id == "ChIJXSModoWLGGARILWiCfeu2M0"
    assert landmark.display_name == "東京駅"
    assert landmark.coordinate == coordinate
    assert landmark.primary_type is None
    assert landmark.types is None
    assert landmark.rating is None


def test_すべてのフィールドを指定して作成できること() -> None:
    """すべてのフィールドを指定してLandmarkを作成できることを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    landmark = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        primary_type="train_station",
        types=["train_station", "transit_station", "point_of_interest"],
        rating=4.5,
    )

    assert landmark.place_id == "ChIJXSModoWLGGARILWiCfeu2M0"
    assert landmark.display_name == "東京駅"
    assert landmark.coordinate == coordinate
    assert landmark.primary_type == "train_station"
    assert landmark.types == ["train_station", "transit_station", "point_of_interest"]
    assert landmark.rating == 4.5


def test_place_idが空文字でValidationErrorが発生すること() -> None:
    """place_idが空文字の場合、ValidationErrorが発生することを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    with pytest.raises(ValidationError):
        Landmark(
            place_id="",
            display_name="東京駅",
            coordinate=coordinate,
        )


def test_display_nameが空文字でValidationErrorが発生すること() -> None:
    """display_nameが空文字の場合、ValidationErrorが発生することを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    with pytest.raises(ValidationError):
        Landmark(
            place_id="ChIJXSModoWLGGARILWiCfeu2M0",
            display_name="",
            coordinate=coordinate,
        )


def test_ratingが0未満でValidationErrorが発生すること() -> None:
    """ratingが0未満の場合、ValidationErrorが発生することを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    with pytest.raises(ValidationError):
        Landmark(
            place_id="ChIJXSModoWLGGARILWiCfeu2M0",
            display_name="東京駅",
            coordinate=coordinate,
            rating=-0.1,
        )


def test_ratingが5超過でValidationErrorが発生すること() -> None:
    """ratingが5.0を超える場合、ValidationErrorが発生することを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    with pytest.raises(ValidationError):
        Landmark(
            place_id="ChIJXSModoWLGGARILWiCfeu2M0",
            display_name="東京駅",
            coordinate=coordinate,
            rating=5.1,
        )


def test_ratingの境界値で作成できること() -> None:
    """ratingの境界値 (0.0と5.0) でLandmarkを作成できることを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    landmark_min = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        rating=0.0,
    )
    landmark_max = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        rating=5.0,
    )

    assert landmark_min.rating == 0.0
    assert landmark_max.rating == 5.0


def test_不変性が保証されていること() -> None:
    """frozen=Trueにより不変性が保証されていることを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    landmark = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
    )

    # 属性の変更を試みるとエラーが発生する
    with pytest.raises((TypeError, ValueError)):
        landmark.place_id = "new_place_id"  # type: ignore[misc]


def test_同じ値のLandmarkが等しいこと() -> None:
    """同じ値のLandmarkが等しいことを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    landmark1 = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        primary_type="train_station",
        types=["train_station"],
        rating=4.5,
    )
    landmark2 = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        primary_type="train_station",
        types=["train_station"],
        rating=4.5,
    )

    assert landmark1 == landmark2


def test_異なる値のLandmarkが等しくないこと() -> None:
    """異なる値のLandmarkが等しくないことを確認"""
    coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
    coordinate2 = Coordinate(latitude=35.6586, longitude=139.7014)

    landmark1 = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate1,
    )
    landmark2 = Landmark(
        place_id="ChIJqTb_hBOLGGARlpGNBdS1Z4E",
        display_name="渋谷駅",
        coordinate=coordinate2,
    )

    assert landmark1 != landmark2


def test_異なる型のオブジェクトと等しくないこと() -> None:
    """異なる型のオブジェクトと等しくないことを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    landmark = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
    )

    assert landmark != "not a landmark"
    assert landmark != 123
    assert landmark != {"place_id": "ChIJXSModoWLGGARILWiCfeu2M0"}


def test_hashメソッドが正しく動作すること() -> None:
    """__hash__メソッドが正しく動作することを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    landmark1 = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
    )
    landmark2 = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
    )
    landmark3 = Landmark(
        place_id="ChIJqTb_hBOLGGARlpGNBdS1Z4E",
        display_name="渋谷駅",
        coordinate=coordinate,
    )

    # 同じ値の場合は同じハッシュ値を持つ
    assert hash(landmark1) == hash(landmark2)
    # 異なる値の場合は異なるハッシュ値を持つ (通常)
    assert hash(landmark1) != hash(landmark3)


def test_typesがNoneでない場合に正しく設定されること() -> None:
    """typesフィールドが正しく設定されることを確認"""
    coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

    # 空リストでも作成可能
    landmark_empty_types = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        types=[],
    )
    assert landmark_empty_types.types == []

    # 複数のtypesを持つ場合
    landmark_multiple_types = Landmark(
        place_id="ChIJXSModoWLGGARILWiCfeu2M0",
        display_name="東京駅",
        coordinate=coordinate,
        types=["train_station", "transit_station", "establishment"],
    )
    assert landmark_multiple_types.types == [
        "train_station",
        "transit_station",
        "establishment",
    ]
