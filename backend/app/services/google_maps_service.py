"""Google Maps API呼び出しサービス

Google Maps API (Street View, Directions) へのリクエストを処理します。
"""

import functools
import logging

import requests
from fastapi import HTTPException
from requests.exceptions import RequestException, Timeout

from app.config import GOOGLE_API_KEY, REQUEST_TIMEOUT_SECONDS
from app.value_objects import Latitude, Longitude

logger = logging.getLogger(__name__)


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
def fetch_directions(origin: str, destination: str) -> dict:
    """Google Directions APIからルート情報を取得(キャッシュ付き)

    Args:
        origin: 出発地の座標 ("緯度,経度"形式)
        destination: 目的地の座標 ("緯度,経度"形式)

    Returns:
        dict: Directions APIのレスポンスデータ
    """
    url = "https://maps.googleapis.com/maps/api/directions/json"
    params = {"origin": origin, "destination": destination, "key": GOOGLE_API_KEY}

    try:
        response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
        data = response.json()

        if data["status"] != "OK":
            logger.error(f"Directions API returned non-OK status: {data['status']}")
            raise HTTPException(status_code=400, detail=f"Directions API error: {data['status']}")

        return data
    except Timeout as e:
        logger.error("Timeout error while fetching directions.")
        raise HTTPException(
            status_code=504, detail="Request timeout: Failed to retrieve directions"
        ) from e
    except RequestException as e:
        logger.error(f"Request error while fetching directions: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve directions: {e}") from e
