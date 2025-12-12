"""ルート生成サービス

ルート生成のビジネスロジックを処理します。
"""

import base64
import logging

import folium
from fastapi import HTTPException

from app.models import MidPoint, Point, RouteResponse
from app.services.google_maps_service import (
    fetch_directions,
    fetch_street_view_image,
    fetch_street_view_metadata,
)
from app.utils.geometry import decode_polyline, generate_random_point

logger = logging.getLogger(__name__)


def get_street_view_image_data(latitude: float, longitude: float, size: str) -> dict:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        dict: メタデータと画像データを含む辞書
    """
    # メタデータの取得(キャッシュ付き)
    metadata = fetch_street_view_metadata(latitude, longitude)

    if metadata["status"] == "OK":
        # メタデータから画像の実際の位置情報を取得
        metadata_latitude = metadata["location"]["lat"]
        metadata_longitude = metadata["location"]["lng"]
        logger.info(
            f"Actual Image Location: Latitude {metadata_latitude}, Longitude {metadata_longitude}"
        )
    else:
        # ステータスが'OK'でない場合のエラーハンドリング
        logger.error("Street View metadata API returned a non-OK status for a requested location.")
        raise HTTPException(
            status_code=400, detail=f"Street View metadata unavailable: {metadata['status']}."
        )

    # Street View Static APIから画像を取得(キャッシュ付き)
    image_content = fetch_street_view_image(latitude, longitude, size)

    # 画像データをBase64エンコードして文字列に変換
    image_data = base64.b64encode(image_content).decode("utf-8")

    # 緯度経度データと画像データをJSON形式で返す
    return {
        "metadata_latitude": metadata_latitude,
        "metadata_longitude": metadata_longitude,
        "original_latitude": latitude,
        "original_longitude": longitude,
        "image_data": image_data,
    }


def generate_route(current_lat: str, current_lng: str, radius: str) -> RouteResponse:
    """ルートを生成

    Args:
        current_lat: 現在の緯度
        current_lng: 現在の経度
        radius: 半径

    Returns:
        RouteResponse: ルート情報
    """
    origin = f"{current_lat},{current_lng}"

    # ランダムな目的地を生成
    destination_lat, destination_lng = generate_random_point(current_lat, current_lng, radius)
    destination = f"{destination_lat},{destination_lng}"

    # Directions APIからルート情報を取得(キャッシュ付き)
    data = fetch_directions(origin, destination)

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

    # 中間地点の画像とメタデータの緯度経度取得
    midpoint_image_data = None
    midpoint_image_lat = None
    midpoint_image_lng = None
    try:
        photo_data = get_street_view_image_data(midpoint_lat, midpoint_lng, "600x300")
        midpoint_image_data = photo_data.get("image_data")
        midpoint_image_lat = photo_data.get("metadata_latitude")
        midpoint_image_lng = photo_data.get("metadata_longitude")
    except HTTPException:
        # Street View画像が取得できない場合は画像情報なしで続行
        logger.warning(
            f"Failed to fetch Street View image for midpoint at {midpoint_lat}, {midpoint_lng}"
        )

    # 最終地点の画像とメタデータの緯度経度取得
    destination_image_data = None
    destination_image_lat = None
    destination_image_lng = None
    try:
        destination_photo_data = get_street_view_image_data(
            destination_lat, destination_lng, "600x300"
        )
        destination_image_data = destination_photo_data.get("image_data")
        destination_image_lat = destination_photo_data.get("metadata_latitude")
        destination_image_lng = destination_photo_data.get("metadata_longitude")
    except HTTPException:
        # Street View画像が取得できない場合は画像情報なしで続行
        logger.warning(
            f"Failed to fetch Street View image for destination at "
            f"{destination_lat}, {destination_lng}"
        )

    # 出力用のデータを準備
    return RouteResponse(
        departure=Point(latitude=float(departure_lat), longitude=float(departure_lng)),
        destination=MidPoint(
            latitude=float(destination_lat),
            longitude=float(destination_lng),
            image_latitude=(
                float(destination_image_lat) if destination_image_lat is not None else None
            ),
            image_longitude=(
                float(destination_image_lng) if destination_image_lng is not None else None
            ),
            image_utf8=destination_image_data,
        ),
        midpoints=[
            MidPoint(
                latitude=float(midpoint_lat),
                longitude=float(midpoint_lng),
                image_latitude=(
                    float(midpoint_image_lat) if midpoint_image_lat is not None else None
                ),
                image_longitude=(
                    float(midpoint_image_lng) if midpoint_image_lng is not None else None
                ),
                image_utf8=midpoint_image_data,
            )
        ],
        overview_polyline=data["routes"][0]["overview_polyline"]["points"],
    )
