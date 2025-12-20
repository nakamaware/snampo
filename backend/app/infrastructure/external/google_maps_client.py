"""Google Maps API呼び出しクライアント

Google Maps API (Street View, Directions) へのリクエストを処理します。
"""

import functools
import logging

import requests
from fastapi import HTTPException
from requests.exceptions import RequestException, Timeout

from app.config import GOOGLE_API_KEY, REQUEST_TIMEOUT_SECONDS
from app.domain.value_objects import Coordinate, Latitude, Longitude

logger = logging.getLogger(__name__)


def decode_polyline(polyline_str: str) -> list[Coordinate]:
    """Google Maps APIのポリラインをデコードして座標リストを生成

    Args:
        polyline_str: ポリラインの文字列

    Returns:
        list[Coordinate]: 座標リスト
    """
    index = 0
    coordinates = []
    lat = 0
    lng = 0

    while index < len(polyline_str):
        shift = 0
        result = 0
        while True:
            byte = ord(polyline_str[index]) - 63
            index += 1
            result |= (byte & 0x1F) << shift
            shift += 5
            if byte < 0x20:
                break

        dlat = ~(result >> 1) if result & 1 else (result >> 1)
        lat += dlat

        shift = 0
        result = 0
        while True:
            byte = ord(polyline_str[index]) - 63
            index += 1
            result |= (byte & 0x1F) << shift
            shift += 5
            if byte < 0x20:
                break

        dlng = ~(result >> 1) if result & 1 else (result >> 1)
        lng += dlng

        lat_float = lat * 1e-5
        lng_float = lng * 1e-5
        coordinates.append(Coordinate(latitude=lat_float, longitude=lng_float))

    return coordinates


def coordinate_to_lat_lng_string(coordinate: Coordinate) -> str:
    """座標をGoogle Maps API用の文字列形式に変換

    Args:
        coordinate: 座標値オブジェクト

    Returns:
        str: "緯度,経度"形式の文字列
    """
    return f"{coordinate.latitude.to_float()},{coordinate.longitude.to_float()}"


@functools.lru_cache(maxsize=128)
def fetch_street_view_metadata(latitude: Latitude, longitude: Longitude) -> dict:
    """Street View Metadata APIからメタデータを取得 (キャッシュ付き)

    Args:
        latitude: 緯度
        longitude: 経度

    Returns:
        dict: メタデータ
    """
    lat_float = latitude.to_float()
    lng_float = longitude.to_float()
    metadata_url = (
        f"https://maps.googleapis.com/maps/api/streetview/metadata"
        f"?location={lat_float},{lng_float}&key={GOOGLE_API_KEY}"
    )

    try:
        metadata_response = requests.get(metadata_url, timeout=REQUEST_TIMEOUT_SECONDS)
        metadata_response.raise_for_status()
        return metadata_response.json()
    except Timeout as e:
        logger.error("Timeout error while fetching Street View metadata for a requested location.")
        raise HTTPException(
            status_code=504, detail="Request timeout: Failed to retrieve Street View metadata"
        ) from e
    except RequestException as e:
        logger.error(f"Request error while fetching Street View metadata: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to retrieve Street View metadata: {e}"
        ) from e


@functools.lru_cache(maxsize=128)
def fetch_street_view_image(latitude: Latitude, longitude: Longitude, size: str) -> bytes:
    """Street View Static APIから画像を取得 (キャッシュ付き)

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        bytes: 画像データ
    """
    lat_float = latitude.to_float()
    lng_float = longitude.to_float()
    url = "https://maps.googleapis.com/maps/api/streetview"
    params = {"size": size, "location": f"{lat_float},{lng_float}", "key": GOOGLE_API_KEY}

    try:
        response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
        return response.content
    except Timeout as e:
        logger.error("Timeout error while fetching Street View image for a requested location.")
        raise HTTPException(
            status_code=504, detail="Request timeout: Failed to retrieve Street View image"
        ) from e
    except RequestException as e:
        logger.error(f"Request error while fetching Street View image: {e}")
        raise HTTPException(
            status_code=500, detail=f"Failed to retrieve Street View image: {e}"
        ) from e


@functools.lru_cache(maxsize=128)
def fetch_directions(origin: Coordinate, destination: Coordinate) -> tuple[list[Coordinate], str]:
    """Google Directions APIからルート情報を取得(キャッシュ付き)

    Args:
        origin: 出発地の座標
        destination: 目的地の座標

    Returns:
        tuple[list[Coordinate], str]:
            (ルート座標リスト, overview_polyline文字列)
    """
    origin_str = coordinate_to_lat_lng_string(origin)
    destination_str = coordinate_to_lat_lng_string(destination)
    url = "https://maps.googleapis.com/maps/api/directions/json"
    params = {"origin": origin_str, "destination": destination_str, "key": GOOGLE_API_KEY}

    try:
        response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
        data = response.json()

        if data["status"] != "OK":
            logger.error(f"Directions API returned non-OK status: {data['status']}")
            raise HTTPException(status_code=400, detail=f"Directions API error: {data['status']}")

        # インフラストラクチャ層で変換処理を行う
        route_coordinates: list[Coordinate] = []
        for step in data["routes"][0]["legs"][0]["steps"]:
            route_coordinates.extend(decode_polyline(step["polyline"]["points"]))

        overview_polyline = data["routes"][0]["overview_polyline"]["points"]

        return route_coordinates, overview_polyline
    except Timeout as e:
        logger.error("Timeout error while fetching directions.")
        raise HTTPException(
            status_code=504, detail="Request timeout: Failed to retrieve directions"
        ) from e
    except RequestException as e:
        logger.error(f"Request error while fetching directions: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve directions: {e}") from e
