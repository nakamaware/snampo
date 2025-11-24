import base64
from fastapi import FastAPI, HTTPException, Response
from typing import Optional
import requests
from requests.exceptions import Timeout, RequestException
import os
import math
import random
import folium
import logging
from dotenv import load_dotenv

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

def generate_random_point(center_lat_str, center_lng_str, radius_str):
    center_lat = float(center_lat_str)
    center_lng = float(center_lng_str)
    radius = float(radius_str)
    
    radius_in_degrees = radius / 111300 

    random_angle = random.uniform(0, 2 * math.pi)

    # Calculate new coordinates
    new_lat = center_lat + (radius_in_degrees * math.cos(random_angle))
    new_lng = center_lng + (radius_in_degrees * math.sin(random_angle))
    
    return new_lat, new_lng

def decode_polyline(polyline_str):
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
def get_street_view_image(latitude: float, longitude: float, size: Optional[str] = "600x300"):

    # 1. Street View Image Metadata APIのURL
    metadata_url = f"https://maps.googleapis.com/maps/api/streetview/metadata?location={latitude},{longitude}&key={GOOGLE_API_KEY}"
    
    # メタデータの取得
    try:
        metadata_response = requests.get(metadata_url, timeout=REQUEST_TIMEOUT_SECONDS)
        metadata_response.raise_for_status()
        metadata = metadata_response.json()
    except Timeout:
        logger.error(f"Timeout error while fetching Street View metadata for location ({latitude}, {longitude})")
        raise HTTPException(status_code=504, detail="Request timeout: Failed to retrieve Street View metadata")
    except RequestException as e:
        logger.error(f"Request error while fetching Street View metadata: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve Street View metadata: {str(e)}")

    if metadata['status'] == 'OK':
        # メタデータから画像の実際の位置情報を取得
        metadata_latitude = metadata['location']['lat']
        metadata_longitude = metadata['location']['lng']
        logger.info(f"Actual Image Location: Latitude {metadata_latitude}, Longitude {metadata_longitude}")
    else:
        # ステータスが'OK'でない場合のエラーハンドリング
        logger.error(
            f"Street View metadata API returned status '{metadata['status']}' for location ({latitude}, {longitude})."
        )
        raise HTTPException(
            status_code=400,
            detail=f"Street View metadata unavailable: {metadata['status']}."
        )

    # Street View Static API の URL を構築
    url = "https://maps.googleapis.com/maps/api/streetview"
    
    # リクエストパラメータを設定
    params = {
        "size": size,
        "location": f"{latitude},{longitude}",
        "key": GOOGLE_API_KEY
    }

    # Street View Static API にリクエストを送信
    try:
        response = requests.get(url, params=params, timeout=REQUEST_TIMEOUT_SECONDS)
        response.raise_for_status()
    except Timeout:
        logger.error(f"Timeout error while fetching Street View image for location ({latitude}, {longitude})")
        raise HTTPException(status_code=504, detail="Request timeout: Failed to retrieve Street View image")
    except RequestException as e:
        logger.error(f"Request error while fetching Street View image: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve Street View image: {str(e)}")
 
    # リクエストが成功した場合
    if response.status_code == 200:
        # 画像データをBase64エンコードして文字列に変換
        image_data = base64.b64encode(response.content).decode("utf-8")
        # 緯度経度データと画像データをJSON形式で返す
        return {
            "metadata_latitude": metadata_latitude,
            "metadata_longitude": metadata_longitude,
            "original_latitude": latitude,
            "original_longitude": longitude,
            "image_data": image_data
        }
    else:
        # エラーが発生した場合はエラーレスポンスを返す
        raise HTTPException(status_code=response.status_code, detail="Failed to retrieve Street View image")

@app.get("/route")
def route(currentLat: str, currentLng: str, radius: str):
    origin = f"{currentLat},{currentLng}"
    url = "https://maps.googleapis.com/maps/api/directions/json?"

    # ランダムな目的地を生成
    destination_lat, destination_lng = generate_random_point(currentLat, currentLng, radius)
    
    # Directions API へのリクエストパラメータの設定
    payload = {
        "origin": origin,
        "destination": f"{destination_lat},{destination_lng}",
        "key": GOOGLE_API_KEY,
        "mode": "walking"
    }

    # Directions API へのリクエストを送信
    try:
        r = requests.get(url, params=payload, timeout=REQUEST_TIMEOUT_SECONDS)
        r.raise_for_status()
    except Timeout:
        logger.error(f"Timeout error while fetching directions from ({currentLat}, {currentLng})")
        raise HTTPException(status_code=504, detail="Request timeout: Failed to retrieve directions")
    except RequestException as e:
        logger.error(f"Request error while fetching directions: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to retrieve directions: {str(e)}")

    # リクエストが成功した場合
    if r.status_code == 200:
        # JSON データを取得
        data = r.json()

        # ルートの座標を取得
        route_coordinates = []
        for step in data["routes"][0]["legs"][0]["steps"]:
            # ステップごとの詳細なルート情報を取得
            for polyline in decode_polyline(step["polyline"]["points"]):
                route_coordinates.append((polyline[0], polyline[1]))

        # 中心の座標を設定
        center = route_coordinates[len(route_coordinates) // 2]

        # 出発地点の座標を取得
        departure_lat, departure_lng = currentLat, currentLng

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
        folium.Marker(location=(float(departure_lat), float(departure_lng)), popup='Departure', icon=folium.Icon(color='green')).add_to(m)

        # 目的地にマーカーを追加
        folium.Marker(location=(float(destination_lat), float(destination_lng)), popup='Destination', icon=folium.Icon(color='red')).add_to(m)

        # 中間地点にマーカーを追加
        folium.Marker(location=(float(midpoint_lat), float(midpoint_lng)), popup='Midpoint', icon=folium.Icon(color='orange')).add_to(m)

        # マップを保存
        m.save("route.html")

        #中間地点の画像とメタデータの緯度経度取得
        photo_data = get_street_view_image(midpoint_lat, midpoint_lng,"600x300")

        # 出力用のデータを準備
        output_data = {
            "departure": {"latitude": float(departure_lat), "longitude": float(departure_lng)},
            "destination": {"latitude": float(destination_lat), "longitude": float(destination_lng)},
            "midpoint": {"latitude": float(midpoint_lat), "longitude": float(midpoint_lng)},
            "midpoint_photo": photo_data,
            "overview_polyline": data["routes"][0]["overview_polyline"]["points"]
        }

        return output_data
    else:
        return "500: Backend error"
