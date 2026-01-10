"""Google Maps Gatewayのキャッシュ機能のテスト"""

from unittest.mock import MagicMock, patch

import pytest
from requests.exceptions import HTTPError

from app.domain.exceptions import ExternalServiceError
from app.domain.value_objects import Coordinate, ImageSize, Landmark
from app.infrastructure.gateways.google_maps_gateway_impl import GoogleMapsGatewayImpl


class TestGetDirections:
    """GetDirectionsのテスト"""

    def test_同じ引数で複数回呼び出したときにキャッシュが効くこと(self) -> None:
        """同じ引数で複数回呼び出したときに、APIリクエストが1回だけになることを確認"""
        origin = Coordinate(latitude=35.6812, longitude=139.7671)
        destination = Coordinate(latitude=35.6895, longitude=139.6917)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 同じ引数で3回呼び出す
            gateway.get_directions(origin, destination)
            gateway.get_directions(origin, destination)
            gateway.get_directions(origin, destination)

            # APIリクエストは1回だけ呼ばれるべき
            assert mock_get.call_count == 1

    def test_異なる引数で呼び出したときにそれぞれ別のリクエストが発生すること(self) -> None:
        """異なる引数で呼び出したときに、それぞれ別のリクエストが発生することを確認"""
        origin1 = Coordinate(latitude=35.6812, longitude=139.7671)
        destination1 = Coordinate(latitude=35.6895, longitude=139.6917)

        origin2 = Coordinate(latitude=35.6586, longitude=139.7454)
        destination2 = Coordinate(latitude=35.6762, longitude=139.6503)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 異なる引数で呼び出す
            gateway.get_directions(origin1, destination1)
            gateway.get_directions(origin2, destination2)

            # APIリクエストは2回呼ばれるべき
            assert mock_get.call_count == 2

    def test_waypointsを指定したときにリクエストパラメータに含まれること(self) -> None:
        """waypointsを指定したときに、リクエストパラメータにwaypointsが含まれることを確認"""
        origin = Coordinate(latitude=35.6812, longitude=139.7671)
        destination = Coordinate(latitude=35.6895, longitude=139.6917)
        waypoint = Coordinate(latitude=35.6850, longitude=139.7300)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            gateway.get_directions(origin, destination, waypoints=[waypoint])

            # リクエストパラメータにwaypointsが含まれていることを確認
            call_args = mock_get.call_args
            assert call_args is not None
            params = call_args.kwargs.get("params", {})
            assert "waypoints" in params
            assert params["waypoints"] == "via:35.685,139.73"

    def test_複数のwaypointsを指定したときにパイプで連結されること(self) -> None:
        """複数のwaypointsを指定したときに、パイプで連結されることを確認"""
        origin = Coordinate(latitude=35.6812, longitude=139.7671)
        destination = Coordinate(latitude=35.6895, longitude=139.6917)
        waypoint1 = Coordinate(latitude=35.6850, longitude=139.7300)
        waypoint2 = Coordinate(latitude=35.6870, longitude=139.7100)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            gateway.get_directions(origin, destination, waypoints=[waypoint1, waypoint2])

            # リクエストパラメータにwaypointsがパイプで連結されて含まれていることを確認
            call_args = mock_get.call_args
            assert call_args is not None
            params = call_args.kwargs.get("params", {})
            assert "waypoints" in params
            assert params["waypoints"] == "via:35.685,139.73|via:35.687,139.71"

    def test_waypointsを指定しないときにリクエストパラメータに含まれないこと(self) -> None:
        """waypointsを指定しないときに、リクエストパラメータにwaypointsが含まれないことを確認"""
        origin = Coordinate(latitude=35.6812, longitude=139.7671)
        destination = Coordinate(latitude=35.6895, longitude=139.6917)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            gateway.get_directions(origin, destination)

            # リクエストパラメータにwaypointsが含まれていないことを確認
            call_args = mock_get.call_args
            assert call_args is not None
            params = call_args.kwargs.get("params", {})
            assert "waypoints" not in params

    def test_同じwaypointsで複数回呼び出したときにキャッシュが効くこと(self) -> None:
        """同じwaypointsで複数回呼び出したときに、APIリクエストが1回だけになることを確認"""
        origin = Coordinate(latitude=35.6812, longitude=139.7671)
        destination = Coordinate(latitude=35.6895, longitude=139.6917)
        waypoint = Coordinate(latitude=35.6850, longitude=139.7300)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 同じ引数で3回呼び出す
            gateway.get_directions(origin, destination, waypoints=[waypoint])
            gateway.get_directions(origin, destination, waypoints=[waypoint])
            gateway.get_directions(origin, destination, waypoints=[waypoint])

            # APIリクエストは1回だけ呼ばれるべき
            assert mock_get.call_count == 1

    def test_異なるwaypointsで呼び出したときに別のリクエストが発生すること(self) -> None:
        """異なるwaypointsで呼び出したときに、それぞれ別のリクエストが発生することを確認"""
        origin = Coordinate(latitude=35.6812, longitude=139.7671)
        destination = Coordinate(latitude=35.6895, longitude=139.6917)
        waypoint1 = Coordinate(latitude=35.6850, longitude=139.7300)
        waypoint2 = Coordinate(latitude=35.6870, longitude=139.7100)

        mock_response_data = {
            "status": "OK",
            "routes": [
                {
                    "legs": [{"steps": [{"polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"}}]}],
                    "overview_polyline": {"points": "_p~iF~ps|U_ulLnnqC_mqNvxq`@"},
                }
            ],
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 異なるwaypointsで呼び出す
            gateway.get_directions(origin, destination, waypoints=[waypoint1])
            gateway.get_directions(origin, destination, waypoints=[waypoint2])

            # APIリクエストは2回呼ばれるべき
            assert mock_get.call_count == 2


class TestGetStreetViewMetadata:
    """GetStreetViewMetadataのテスト"""

    def test_同じ引数で複数回呼び出したときにキャッシュが効くこと(self) -> None:
        """同じ引数で複数回呼び出したときに、APIリクエストが1回だけになることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)

        mock_response_data = {
            "status": "OK",
            "location": {"lat": 35.6812, "lng": 139.7671},
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 同じ引数で3回呼び出す
            gateway.get_street_view_metadata(coordinate)
            gateway.get_street_view_metadata(coordinate)
            gateway.get_street_view_metadata(coordinate)

            # APIリクエストは1回だけ呼ばれるべき
            assert mock_get.call_count == 1

    def test_異なる引数で別リクエストが発生すること(self) -> None:
        """異なる引数で呼び出したときに、それぞれ別のリクエストが発生することを確認"""
        coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
        coordinate2 = Coordinate(latitude=35.6895, longitude=139.6917)

        mock_response_data = {
            "status": "OK",
            "location": {"lat": 35.6812, "lng": 139.7671},
        }

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 異なる引数で呼び出す
            gateway.get_street_view_metadata(coordinate1)
            gateway.get_street_view_metadata(coordinate2)

            # APIリクエストは2回呼ばれるべき
            assert mock_get.call_count == 2


class TestGetStreetViewImage:
    """GetStreetViewImageのテスト"""

    def test_同じ引数で複数回呼び出したときにキャッシュが効くこと(self) -> None:
        """同じ引数で複数回呼び出したときに、APIリクエストが1回だけになることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        image_size = ImageSize(width=640, height=640)

        mock_image_data = b"fake_image_data"

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.content = mock_image_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 同じ引数で3回呼び出す
            gateway.get_street_view_image(coordinate, image_size)
            gateway.get_street_view_image(coordinate, image_size)
            gateway.get_street_view_image(coordinate, image_size)

            # APIリクエストは1回だけ呼ばれるべき
            assert mock_get.call_count == 1

    def test_異なる引数で別リクエストが発生すること(self) -> None:
        """異なる引数で呼び出したときに、それぞれ別のリクエストが発生することを確認"""
        coordinate1 = Coordinate(latitude=35.6812, longitude=139.7671)
        coordinate2 = Coordinate(latitude=35.6895, longitude=139.6917)
        image_size = ImageSize(width=640, height=640)

        mock_image_data = b"fake_image_data"

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.content = mock_image_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 異なる引数で呼び出す
            gateway.get_street_view_image(coordinate1, image_size)
            gateway.get_street_view_image(coordinate2, image_size)

            # APIリクエストは2回呼ばれるべき
            assert mock_get.call_count == 2

    def test_異なる画像サイズで別リクエストが発生すること(self) -> None:
        """異なる画像サイズで呼び出したときに、それぞれ別のリクエストが発生することを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        image_size1 = ImageSize(width=640, height=640)
        image_size2 = ImageSize(width=320, height=320)

        mock_image_data = b"fake_image_data"

        with patch("app.infrastructure.gateways.google_maps_gateway_impl.requests.get") as mock_get:
            mock_response = MagicMock()
            mock_response.content = mock_image_data
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 異なる画像サイズで呼び出す
            gateway.get_street_view_image(coordinate, image_size1)
            gateway.get_street_view_image(coordinate, image_size2)

            # APIリクエストは2回呼ばれるべき
            assert mock_get.call_count == 2


class TestSearchLandmarksNearby:
    """SearchLandmarksNearbyのテスト"""

    def test_正常なレスポンスからLandmarkリストが返されること(self) -> None:
        """正常なレスポンスからLandmarkリストが返されることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        mock_response_data = {
            "places": [
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
                    "displayName": {"text": "東京駅"},
                    "location": {"latitude": 35.6812, "longitude": 139.7671},
                    "primaryType": "train_station",
                    "types": [
                        "train_station",
                        "transit_station",
                        "point_of_interest",
                        "establishment",
                    ],
                    "rating": 4.5,
                },
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY5",
                    "displayName": {"text": "皇居"},
                    "location": {"latitude": 35.6850, "longitude": 139.7528},
                    "primaryType": "tourist_attraction",
                    "types": ["tourist_attraction", "point_of_interest", "establishment"],
                    "rating": 4.7,
                },
            ]
        }

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            landmarks = gateway.search_landmarks_nearby(coordinate, radius)

            assert mock_post.call_count == 1
            assert len(landmarks) == 2
            assert isinstance(landmarks[0], Landmark)
            assert landmarks[0].place_id == "ChIJN1t_tDeuEmsRUsoyG83frY4"
            assert landmarks[0].display_name == "東京駅"
            assert landmarks[0].coordinate.latitude == 35.6812
            assert landmarks[0].coordinate.longitude == 139.7671
            assert landmarks[0].primary_type == "train_station"
            assert landmarks[0].types == [
                "train_station",
                "transit_station",
                "point_of_interest",
                "establishment",
            ]
            assert landmarks[0].rating == 4.5

    def test_空のレスポンスから空のリストが返されること(self) -> None:
        """空のレスポンスから空のリストが返されることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        mock_response_data = {"places": []}

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            landmarks = gateway.search_landmarks_nearby(coordinate, radius)

            assert mock_post.call_count == 1
            assert len(landmarks) == 0

    def test_座標情報がない場合はスキップされること(self) -> None:
        """座標情報がない場合はスキップされることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        mock_response_data = {
            "places": [
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
                    "displayName": {"text": "東京駅"},
                    "location": {},  # 座標情報なし
                    "primaryType": "train_station",
                },
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY5",
                    "displayName": {"text": "皇居"},
                    "location": {"latitude": 35.6850, "longitude": 139.7528},
                    "primaryType": "tourist_attraction",
                },
            ]
        }

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            landmarks = gateway.search_landmarks_nearby(coordinate, radius)

            assert mock_post.call_count == 1
            # 座標情報がないものはスキップされるため、1件のみ
            assert len(landmarks) == 1
            assert landmarks[0].place_id == "ChIJN1t_tDeuEmsRUsoyG83frY5"

    def test_rank_preference_DISTANCEが指定できること(self) -> None:
        """rank_preference="DISTANCE" が指定できることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        mock_response_data = {
            "places": [
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
                    "displayName": {"text": "東京駅"},
                    "location": {"latitude": 35.6812, "longitude": 139.7671},
                    "primaryType": "train_station",
                    "rating": 4.5,
                },
            ]
        }

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            landmarks = gateway.search_landmarks_nearby(
                coordinate, radius, rank_preference="DISTANCE"
            )

            assert mock_post.call_count == 1
            # リクエストボディで rankPreference が "DISTANCE" に設定されていることを確認
            call_args = mock_post.call_args
            assert call_args is not None
            request_body = call_args.kwargs.get("json", {})
            assert request_body.get("rankPreference") == "DISTANCE"
            assert len(landmarks) == 1

    def test_rank_preference_POPULARITYがデフォルトで使用されること(self) -> None:
        """rank_preference を指定しない場合、デフォルトで "POPULARITY" が使用されることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        mock_response_data = {
            "places": [
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
                    "displayName": {"text": "東京駅"},
                    "location": {"latitude": 35.6812, "longitude": 139.7671},
                    "primaryType": "train_station",
                    "rating": 4.5,
                },
            ]
        }

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            landmarks = gateway.search_landmarks_nearby(coordinate, radius)

            assert mock_post.call_count == 1
            # リクエストボディで rankPreference が "POPULARITY" に設定されていることを確認
            call_args = mock_post.call_args
            assert call_args is not None
            request_body = call_args.kwargs.get("json", {})
            assert request_body.get("rankPreference") == "POPULARITY"
            assert len(landmarks) == 1

    def test_同じ引数で複数回呼び出したときにキャッシュが効くこと(self) -> None:
        """同じ引数で複数回呼び出したときに、APIリクエストが1回だけになることを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        mock_response_data = {
            "places": [
                {
                    "id": "ChIJN1t_tDeuEmsRUsoyG83frY4",
                    "displayName": {"text": "東京駅"},
                    "location": {"latitude": 35.6812, "longitude": 139.7671},
                    "primaryType": "train_station",
                    "rating": 4.5,
                },
            ]
        }

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # 同じ引数で2回呼び出す
            landmarks1 = gateway.search_landmarks_nearby(coordinate, radius)
            landmarks2 = gateway.search_landmarks_nearby(coordinate, radius)

            # APIリクエストは1回だけ呼ばれるべき
            assert mock_post.call_count == 1
            # 結果が同一であることを確認
            assert landmarks1 == landmarks2

    def test_非200ステータスでHTTPErrorが発生すること(self) -> None:
        """非200ステータスでHTTPErrorが発生することを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.status_code = 500
            mock_response.reason = "Internal Server Error"
            http_error = HTTPError("500 Server Error", response=mock_response)
            mock_response.raise_for_status = MagicMock(side_effect=http_error)
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()

            # ExternalServiceErrorが発生することを確認
            with pytest.raises(ExternalServiceError) as exc_info:
                gateway.search_landmarks_nearby(coordinate, radius)

            assert "Places API" in str(exc_info.value)
            assert mock_post.call_count == 1

    def test_不正なJSONレスポンスでエラーが発生すること(self) -> None:
        """不正なJSONレスポンスでエラーが発生することを確認"""
        coordinate = Coordinate(latitude=35.6812, longitude=139.7671)
        radius = 1000

        # 予期しない形状のJSON (placesキーがない)
        mock_response_data = {"error": "Invalid request"}

        with patch(
            "app.infrastructure.gateways.google_maps_gateway_impl.requests.post"
        ) as mock_post:
            mock_response = MagicMock()
            mock_response.json.return_value = mock_response_data
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_post.return_value = mock_response

            gateway = GoogleMapsGatewayImpl()
            landmarks = gateway.search_landmarks_nearby(coordinate, radius)

            # placesキーがない場合、空のリストが返される
            assert mock_post.call_count == 1
            assert len(landmarks) == 0
