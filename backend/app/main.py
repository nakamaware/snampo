import base64
import logging
import math
import os
import secrets

import folium
import requests
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from requests.exceptions import RequestException, Timeout

# Load environment variables from .env file
load_dotenv()

app = FastAPI()

# Configure logging
logger = logging.getLogger(__name__)

# Request timeout constant (in seconds)
REQUEST_TIMEOUT_SECONDS = 15

# Get Google API key from environment variable
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError(
        "GOOGLE_API_KEY environment variable is not set. "
        "Please set it in your .env file or environment variables."
    )


def generate_random_point(
    center_lat_str: str, center_lng_str: str, radius_str: str
) -> tuple[float, float]:
    """指定された中心点から半径内のランダムな地点を生成

    Args:
        center_lat_str: 中心点の緯度
        center_lng_str: 中心点の経度
        radius_str: 半径

    Returns:
        new_lat: 新しい緯度
        new_lng: 新しい経度
    """
    center_lat = float(center_lat_str)
    center_lng = float(center_lng_str)
    radius = float(radius_str)

    radius_in_degrees = radius / 111300

    # Use secrets module for cryptographically secure random number generation
    # Equivalent to random.uniform(0, 2 * math.pi) which is: 0 + (2*pi - 0) * random.random()
    # random.random() returns [0.0, 1.0), so we use secrets.randbelow(2**53) / (2**53) to match
    random_angle = (secrets.randbelow(2**53) / (2**53)) * 2 * math.pi

    # Calculate new coordinates
    new_lat = center_lat + (radius_in_degrees * math.cos(random_angle))
    new_lng = center_lng + (radius_in_degrees * math.sin(random_angle))

    return new_lat, new_lng


def decode_polyline(polyline_str: str) -> list[tuple[float, float]]:
    """ポリラインをデコードして座標リストを生成

    Args:
        polyline_str: ポリラインの文字列

    Returns:
        coordinates: 座標リスト
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

        coordinates.append((lat * 1e-5, lng * 1e-5))

    return coordinates


@app.get("/streetview")
def get_street_view_image(latitude: float, longitude: float, size: str | None = "600x300") -> dict:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        dict: メタデータ
    """
    metadata_url = f"https://maps.googleapis.com/maps/api/streetview/metadata?location={latitude},{longitude}&key={GOOGLE_API_KEY}"

    # メタデータの取得
    try:
        metadata_response = requests.get(metadata_url, timeout=REQUEST_TIMEOUT_SECONDS)
        metadata_response.raise_for_status()
        metadata = metadata_response.json()
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

    if metadata["status"] == "OK":
        # メタデータから画像の実際の位置情報を取得
        metadata_latitude = metadata["location"]["lat"]
        metadata_longitude = metadata["location"]["lng"]
        logger.info(
            f"Actual Image Location: Latitude {metadata_latitude}, Longitude {metadata_longitude}"
        )
    else:
        # ステータスが'OK'でない場合のエラーハンドリング
        logger.error(
            f"Street View metadata API returned status '{metadata['status']}' for a requested location."
        )
        raise HTTPException(
            status_code=400, detail=f"Street View metadata unavailable: {metadata['status']}."
        )

    # Street View Static API の URL を構築
    url = "https://maps.googleapis.com/maps/api/streetview"

    # リクエストパラメータを設定
    params = {"size": size, "location": f"{latitude},{longitude}", "key": GOOGLE_API_KEY}

    # Street View Static API にリクエストを送信
    try:
        response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
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

    if response.status_code != 200:
        raise HTTPException(
            status_code=response.status_code, detail="Failed to retrieve Street View image"
        )

    # 画像データをBase64エンコードして文字列に変換
    image_data = base64.b64encode(response.content).decode("utf-8")

    # 緯度経度データと画像データをJSON形式で返す
    return {
        "metadata_latitude": metadata_latitude,
        "metadata_longitude": metadata_longitude,
        "original_latitude": latitude,
        "original_longitude": longitude,
        "image_data": image_data,
    }


@app.get("/route")
def route(current_lat: str, current_lng: str, radius: str) -> dict | str:
    """ルートを生成

    Args:
        current_lat: 現在の緯度
        current_lng: 現在の経度
        radius: 半径

    Returns:
        dict: ルート
    """
    origin = f"{current_lat},{current_lng}"
    url = "https://maps.googleapis.com/maps/api/directions/json?"

    # ランダムな目的地を生成
    destination_lat, destination_lng = generate_random_point(current_lat, current_lng, radius)

    # Directions API へのリクエストパラメータの設定
    payload = {
        "origin": origin,
        "destination": f"{destination_lat},{destination_lng}",
        "key": GOOGLE_API_KEY,
        "mode": "walking",
    }

    # Directions API へのリクエストを送信
    try:
        r = requests.get(url, params=payload, timeout=REQUEST_TIMEOUT_SECONDS)
        r.raise_for_status()
    except Timeout as e:
        logger.error("Timeout error while fetching directions from a requested location.")
        raise HTTPException(
            status_code=504, detail="Request timeout: Failed to retrieve directions"
        ) from e
    except RequestException as e:
        logger.error(f"Request error while fetching directions: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve directions: {e}") from e

    # リクエストが成功した場合
    if r.status_code != 200:
        return "500: Backend error"

    # JSON データを取得
    data = r.json()

    # ルートの座標を取得
    route_coordinates = []
    for step in data["routes"][0]["legs"][0]["steps"]:
        # ステップごとの詳細なルート情報を取得
        route_coordinates.extend(decode_polyline(step["polyline"]["points"]))

    # 中心の座標を設定
    center = route_coordinates[len(route_coordinates) // 2]

    # 出発地点の座標を取得
    departure_lat, departure_lng = current_lat, current_lng

    # 目的地の座標を取得
    destination_lat, destination_lng = destination_lat, destination_lng

    # 中間地点の座標を計算
    midpoint_index = len(route_coordinates) // 2
    midpoint_lat, midpoint_lng = route_coordinates[midpoint_index]

    # マップを作成
    m = folium.Map(location=center, zoom_start=16)

    # ルートのポリラインを追加
    folium.PolyLine(locations=route_coordinates, color="blue", weight=2.5, opacity=1).add_to(m)

    # 出発地点にマーカーを追加
    folium.Marker(
        location=(float(departure_lat), float(departure_lng)),
        popup="Departure",
        icon=folium.Icon(color="green"),
    ).add_to(m)

    # 目的地にマーカーを追加
    folium.Marker(
        location=(float(destination_lat), float(destination_lng)),
        popup="Destination",
        icon=folium.Icon(color="red"),
    ).add_to(m)

    # 中間地点にマーカーを追加
    folium.Marker(
        location=(float(midpoint_lat), float(midpoint_lng)),
        popup="Midpoint",
        icon=folium.Icon(color="orange"),
    ).add_to(m)

    # マップを保存
    m.save("route.html")

    # 中間地点の画像とメタデータの緯度経度取得
    photo_data = get_street_view_image(midpoint_lat, midpoint_lng, "600x300")

    # 出力用のデータを準備
    return {
        "departure": {"latitude": float(departure_lat), "longitude": float(departure_lng)},
        "destination": {
            "latitude": float(destination_lat),
            "longitude": float(destination_lng),
        },
        "midpoint": {"latitude": float(midpoint_lat), "longitude": float(midpoint_lng)},
        "midpoint_photo": photo_data,
        "overview_polyline": data["routes"][0]["overview_polyline"]["points"],
    }
