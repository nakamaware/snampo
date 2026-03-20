"""GenerateRouteUseCaseのテスト"""

from unittest.mock import MagicMock, patch

from app.application.usecases.generate_route_usecase import GenerateRouteUseCase
from app.config import DIRECTIONS_API_MAX_WAYPOINTS
from app.domain.value_objects import Coordinate, StreetViewImage


def test_execute_目的地指定モードでは距離算出後にミッション地点数を計算すること() -> None:
    """目的地指定モードでradius未指定でもルート生成できることを確認"""
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
        start=current_coordinate,
        end=destination_coordinate,
        num_segments=4,
    )
    google_maps_gateway.get_directions.assert_called_once_with(
        origin=current_coordinate,
        destination=destination_coordinate,
        waypoints=[],
    )
    assert result.destination == destination_coordinate
    assert result.destination_image == destination_image
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

    google_maps_gateway = MagicMock()
    google_maps_gateway.get_directions.return_value = ([], "overview-polyline")
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
        start=current_coordinate,
        end=destination_coordinate,
        num_segments=DIRECTIONS_API_MAX_WAYPOINTS,
    )
    assert result.destination == destination_coordinate
    assert result.destination_image == destination_image
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
