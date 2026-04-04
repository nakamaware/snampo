"""GenerateRouteUseCaseのテスト"""

from unittest.mock import MagicMock, patch

from app.application.usecases.generate_route_usecase import GenerateRouteUseCase
from app.config import DIRECTIONS_API_MAX_WAYPOINTS
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
