"""Google Maps Gatewayのキャッシュ機能のテスト"""

from unittest.mock import MagicMock, patch

from app.domain.value_objects import Coordinate, ImageSize
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
