"""GenerateRouteUseCaseのテスト"""

from unittest.mock import MagicMock, patch

from app.application.usecases.generate_route_usecase import GenerateRouteUseCase
from app.config import DIRECTIONS_API_MAX_WAYPOINTS
from app.domain.services.coordinate_service import calculate_distance as real_calculate_distance
from app.domain.value_objects import Coordinate, Landmark, StreetViewImage


def test_execute_目的地指定モードでは距離算出後にミッション地点数を計算すること() -> None:
    """目的地指定モードでradius未指定でもルート生成できることを確認"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_coordinate,
        image_data=b"destination-image",
    )

    route_coordinates = [
        current_coordinate,
        Coordinate(latitude=35.6850, longitude=139.7300),
        destination_coordinate,
    ]

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    landmark_search_service = MagicMock()
    landmark_selector = MagicMock()
    street_view_image_fetch_service = MagicMock()
    street_view_image_fetch_service.get_image.return_value = destination_image

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.calculate_distance",
            return_value=1200,
        ) as mock_calculate_distance,
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[],
        ) as mock_divide_route_into_segments,
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=4,
        ) as mock_calculate_mission_point_count,
    ):
        result = usecase.execute(
            current_coordinate=current_coordinate,
            destination_coordinate=destination_coordinate,
        )

    mock_calculate_distance.assert_called_once_with(current_coordinate, destination_coordinate)
    mock_calculate_mission_point_count.assert_called_once_with(1200)
    mock_divide_route_into_segments.assert_called_once_with(
        route_coordinates=route_coordinates,
        num_segments=4,
    )
    assert google_maps_gateway.get_directions.call_count == 2
    assert google_maps_gateway.get_directions.call_args_list[0].kwargs == {
        "origin": current_coordinate,
        "destination": destination_coordinate,
        "waypoints": None,
    }
    assert google_maps_gateway.get_directions.call_args_list[1].kwargs == {
        "origin": current_coordinate,
        "destination": destination_coordinate,
        "waypoints": [],
    }
    assert result.destination.coordinate == destination_coordinate
    assert result.destination.street_view_image == destination_image
    assert result.destination.landmark is None
    assert result.midpoints == []


def test_execute_ミッション総数が上限超過なら最大件数にクランプすること() -> None:
    """Directions API 制約を超える mission 数は上限に丸めることを確認"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_coordinate,
        image_data=b"destination-image",
    )

    route_coordinates = [
        current_coordinate,
        Coordinate(latitude=35.6850, longitude=139.7300),
        destination_coordinate,
    ]

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    google_maps_gateway.search_landmarks_nearby.return_value = []
    landmark_search_service = MagicMock()
    landmark_selector = MagicMock()
    street_view_image_fetch_service = MagicMock()
    street_view_image_fetch_service.get_image.return_value = destination_image

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.calculate_distance",
            return_value=20000,
        ),
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[],
        ) as mock_divide_route_into_segments,
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=40,
        ) as mock_calculate_mission_point_count,
    ):
        result = usecase.execute(
            current_coordinate=current_coordinate,
            destination_coordinate=destination_coordinate,
        )

    mock_calculate_mission_point_count.assert_called_once_with(20000)
    mock_divide_route_into_segments.assert_called_once_with(
        route_coordinates=route_coordinates,
        num_segments=DIRECTIONS_API_MAX_WAYPOINTS,
    )
    assert result.destination.coordinate == destination_coordinate
    assert result.destination.street_view_image == destination_image
    assert result.destination.landmark is None
    assert result.midpoints == []


def test_execute_中間地点数が0なら分割関数を呼ばないこと() -> None:
    """中間地点数が0のケースでは分割処理をスキップできることを確認"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_coordinate,
        image_data=b"destination-image",
    )

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.return_value = ([], "overview-polyline")
    landmark_search_service = MagicMock()
    landmark_selector = MagicMock()
    street_view_image_fetch_service = MagicMock()
    street_view_image_fetch_service.get_image.return_value = destination_image

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.calculate_distance",
            return_value=100,
        ),
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[],
        ) as mock_divide_route_into_segments,
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=0,
        ),
    ):
        result = usecase.execute(
            current_coordinate=current_coordinate,
            destination_coordinate=destination_coordinate,
        )

    mock_divide_route_into_segments.assert_not_called()
    google_maps_gateway.get_directions.assert_called_once_with(
        origin=current_coordinate,
        destination=destination_coordinate,
        waypoints=[],
    )
    assert result.midpoints == []


def test_execute_実ルート上の候補地点生成にルート座標列を使うこと() -> None:
    """候補地点の生成が始点終点の直線ではなく取得したルート座標列ベースで行われることを確認"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_coordinate,
        image_data=b"destination-image",
    )
    route_coordinates = [
        current_coordinate,
        Coordinate(latitude=35.6850, longitude=139.7300),
        destination_coordinate,
    ]

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    landmark_search_service = MagicMock()
    landmark_selector = MagicMock()
    street_view_image_fetch_service = MagicMock()
    street_view_image_fetch_service.get_image.return_value = destination_image

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.calculate_distance",
            return_value=1200,
        ),
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[],
        ) as mock_divide_route_into_segments,
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=1,
        ),
    ):
        usecase.execute(
            current_coordinate=current_coordinate,
            destination_coordinate=destination_coordinate,
        )

    mock_divide_route_into_segments.assert_called_once_with(
        route_coordinates=route_coordinates,
        num_segments=1,
    )


def test_execute_ランダムモードではランドマーク情報も結果に含めること() -> None:
    """ランダム選択されたランドマーク情報がDTOへ保持されることを確認"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    midpoint_coordinate = Coordinate(latitude=35.6850, longitude=139.7300)
    route_coordinates = [current_coordinate, midpoint_coordinate, destination_coordinate]
    destination_landmark = Landmark(
        place_id="destination-place-id",
        display_name="Tokyo Tower",
        coordinate=destination_coordinate,
        primary_type="tourist_attraction",
    )
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_landmark.coordinate,
        image_data=b"destination-image",
        heading=123.0,
    )
    midpoint_landmark = Landmark(
        place_id="midpoint-place-id",
        display_name="Zojoji Temple",
        coordinate=midpoint_coordinate,
        primary_type="church",
    )
    midpoint_image = StreetViewImage(
        metadata_coordinate=midpoint_coordinate,
        original_coordinate=midpoint_landmark.coordinate,
        image_data=b"midpoint-image",
        heading=45.0,
    )

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    google_maps_gateway.search_landmarks_nearby.return_value = [midpoint_landmark]
    landmark_search_service = MagicMock()
    landmark_search_service.search_landmarks.return_value = [destination_landmark]
    landmark_selector = MagicMock()
    landmark_selector.select.side_effect = [
        (destination_landmark, destination_image),
        (midpoint_landmark, midpoint_image),
    ]
    street_view_image_fetch_service = MagicMock()

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[midpoint_coordinate],
        ),
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=1,
        ),
    ):
        result = usecase.execute(current_coordinate=current_coordinate, radius_m=1000)

    assert result.destination.coordinate == destination_coordinate
    assert result.destination.street_view_image == destination_image
    assert result.destination.landmark == destination_landmark
    assert len(result.midpoints) == 1
    assert result.midpoints[0].coordinate == midpoint_coordinate
    assert result.midpoints[0].street_view_image == midpoint_image
    assert result.midpoints[0].landmark == midpoint_landmark


def test_filter_midpoint_landmark_candidates_place_idと至近距離で除外すること() -> None:
    """_filter_midpoint_landmark_candidates が used と目的地至近を除くことを確認"""
    destination = Coordinate(latitude=35.6895, longitude=139.6917)
    far = Coordinate(latitude=35.6800, longitude=139.7600)
    lm_used = Landmark(
        place_id="ChIJ_used",
        display_name="Used",
        coordinate=far,
    )
    lm_near_dest = Landmark(
        place_id="ChIJ_near",
        display_name="NearDest",
        coordinate=destination,
    )
    lm_ok = Landmark(
        place_id="ChIJ_ok",
        display_name="Ok",
        coordinate=far,
    )
    used: set[str] = {"ChIJ_used"}
    filtered = GenerateRouteUseCase._filter_midpoint_landmark_candidates(
        [lm_used, lm_near_dest, lm_ok],
        used,
        destination,
    )
    assert len(filtered) == 1
    assert filtered[0].place_id == "ChIJ_ok"


def test_execute_同一place_idの2つ目のセグメントは中間地点を付与しないこと() -> None:
    """2セグメント目で候補がすべて既採用と同一 place_id なら waypoint が1件のまま"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_coordinate,
        image_data=b"destination-image",
    )
    route_coordinates = [
        current_coordinate,
        Coordinate(latitude=35.6850, longitude=139.7300),
        destination_coordinate,
    ]
    lm1 = Landmark(
        place_id="ChIJ_first",
        display_name="First",
        coordinate=Coordinate(latitude=35.6840, longitude=139.7200),
    )
    lm2 = Landmark(
        place_id="ChIJ_second",
        display_name="Second",
        coordinate=Coordinate(latitude=35.6845, longitude=139.7210),
    )
    mid_image = StreetViewImage(
        metadata_coordinate=lm1.coordinate,
        original_coordinate=lm1.coordinate,
        image_data=b"mid-image",
    )

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    google_maps_gateway.search_landmarks_nearby.side_effect = [
        [lm1, lm2],
        [lm1],
    ]
    landmark_search_service = MagicMock()
    landmark_selector = MagicMock()
    landmark_selector.select.return_value = (lm1, mid_image)
    street_view_image_fetch_service = MagicMock()
    street_view_image_fetch_service.get_image.return_value = destination_image

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[
                Coordinate(latitude=35.6830, longitude=139.7150),
                Coordinate(latitude=35.6835, longitude=139.7160),
            ],
        ),
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=2,
        ),
    ):
        result = usecase.execute(
            current_coordinate=current_coordinate,
            destination_coordinate=destination_coordinate,
        )

    assert len(result.midpoints) == 1
    assert result.midpoints[0].coordinate == mid_image.metadata_coordinate
    assert result.midpoints[0].street_view_image == mid_image
    assert result.midpoints[0].landmark == lm1
    assert landmark_selector.select.call_count == 1
    assert google_maps_gateway.get_directions.call_args_list[1].kwargs["waypoints"] == [
        mid_image.metadata_coordinate
    ]


def test_execute_候補が目的地と至近のみなら中間地点を付与しないこと() -> None:
    """フィルタ後に候補が空なら get_directions の waypoints は空"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    destination_coordinate = Coordinate(latitude=35.6895, longitude=139.6917)
    destination_image = StreetViewImage(
        metadata_coordinate=destination_coordinate,
        original_coordinate=destination_coordinate,
        image_data=b"destination-image",
    )
    route_coordinates = [
        current_coordinate,
        Coordinate(latitude=35.6850, longitude=139.7300),
        destination_coordinate,
    ]
    lm_at_dest = Landmark(
        place_id="ChIJ_at_dest",
        display_name="AtDest",
        coordinate=destination_coordinate,
    )

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    google_maps_gateway.search_landmarks_nearby.return_value = [lm_at_dest]
    landmark_search_service = MagicMock()
    landmark_selector = MagicMock()
    street_view_image_fetch_service = MagicMock()
    street_view_image_fetch_service.get_image.return_value = destination_image

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    def distance_side_effect(a: Coordinate, b: Coordinate) -> float:
        if a == current_coordinate and b == destination_coordinate:
            return 1200.0
        return real_calculate_distance(a, b)

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.calculate_distance",
            side_effect=distance_side_effect,
        ),
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[Coordinate(latitude=35.6850, longitude=139.7300)],
        ),
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=1,
        ),
    ):
        result = usecase.execute(
            current_coordinate=current_coordinate,
            destination_coordinate=destination_coordinate,
        )

    assert result.midpoints == []
    landmark_selector.select.assert_not_called()
    assert google_maps_gateway.get_directions.call_args_list[1].kwargs["waypoints"] == []


def test_execute_ランダムモードで目的地と同一place_idの中間候補はスキップされること() -> None:
    """ランダム目的地の place_id を used に入れ、同一 ID の中間候補は採用しない"""
    current_coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
    dest_coord = Coordinate(latitude=35.6895, longitude=139.6917)
    dest_landmark = Landmark(
        place_id="ChIJ_dest",
        display_name="Dest",
        coordinate=dest_coord,
    )
    dest_image = StreetViewImage(
        metadata_coordinate=dest_coord,
        original_coordinate=dest_coord,
        image_data=b"destination-image",
    )
    route_coordinates = [
        current_coordinate,
        Coordinate(latitude=35.6850, longitude=139.7300),
        dest_coord,
    ]

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.side_effect = [
        (route_coordinates, "initial-overview-polyline"),
        ([], "overview-polyline"),
    ]
    google_maps_gateway.search_landmarks_nearby.return_value = [dest_landmark]
    landmark_search_service = MagicMock()
    landmark_search_service.search_landmarks.return_value = [dest_landmark]
    landmark_selector = MagicMock()
    landmark_selector.select.return_value = (dest_landmark, dest_image)
    street_view_image_fetch_service = MagicMock()

    usecase = GenerateRouteUseCase(
        google_maps_gateway=google_maps_gateway,
        landmark_search_service=landmark_search_service,
        landmark_selector=landmark_selector,
        street_view_image_fetch_service=street_view_image_fetch_service,
    )

    with (
        patch(
            "app.application.usecases.generate_route_usecase.coordinate_service.divide_route_into_segments",
            return_value=[Coordinate(latitude=35.6850, longitude=139.7300)],
        ),
        patch(
            "app.application.usecases.generate_route_usecase.calculate_mission_point_count",
            return_value=1,
        ),
    ):
        result = usecase.execute(
            current_coordinate=current_coordinate,
            radius_m=1000,
        )

    assert result.destination.coordinate == dest_coord
    assert result.destination.street_view_image == dest_image
    assert result.destination.landmark == dest_landmark
    assert result.midpoints == []
    assert landmark_selector.select.call_count == 1
    assert google_maps_gateway.get_directions.call_args_list[1].kwargs["waypoints"] == []
