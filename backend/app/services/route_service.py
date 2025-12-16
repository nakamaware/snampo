"""ルート生成サービス

ルート生成のビジネスロジックを処理します。
"""

import base64
import logging

import folium
from fastapi import HTTPException

from app.models import MidPoint, Point, RouteResponse, StreetViewImageResponse
from app.services.google_maps_service import (
    fetch_directions,
    fetch_street_view_image,
    fetch_street_view_metadata,
)
from app.utils.geometry import decode_polyline, generate_random_point
from app.value_objects import Latitude, Longitude

logger = logging.getLogger(__name__)


def get_street_view_image_data(
    latitude: float, longitude: float, size: str
) -> StreetViewImageResponse:
    """Street View Image Metadata APIを使用して画像のメタデータを取得

    Args:
        latitude: 緯度
        longitude: 経度
        size: 画像サイズ

    Returns:
        StreetViewImageResponse: メタデータと画像データ
    """
    # 値オブジェクトに変換 (バリデーションも実行される)
    lat_vo = Latitude(value=latitude)
    lng_vo = Longitude(value=longitude)

    # メタデータの取得(キャッシュ付き)
    metadata = fetch_street_view_metadata(lat_vo, lng_vo)

    if metadata["status"] == "OK":
        # メタデータから画像の実際の位置情報を取得
        metadata_latitude = Latitude(value=metadata["location"]["lat"])
        metadata_longitude = Longitude(value=metadata["location"]["lng"])
        logger.info(
            f"Actual Image Location: Latitude {metadata_latitude.to_float()}, "
            f"Longitude {metadata_longitude.to_float()}"
        )
    else:
        # ステータスが'OK'でない場合のエラーハンドリング
        logger.error("Street View metadata API returned a non-OK status for a requested location.")
        raise HTTPException(
            status_code=400, detail=f"Street View metadata unavailable: {metadata['status']}."
        )

    # Street View Static APIから画像を取得(キャッシュ付き)
    image_content = fetch_street_view_image(lat_vo, lng_vo, size)

    # 画像データをBase64エンコードして文字列に変換
    image_data = base64.b64encode(image_content).decode("utf-8")

    # StreetViewImageResponseインスタンスを返す
    return StreetViewImageResponse(
        metadata_latitude=metadata_latitude,
        metadata_longitude=metadata_longitude,
        original_latitude=lat_vo,
        original_longitude=lng_vo,
        image_data=image_data,
    )


def generate_route(current_lat: float, current_lng: float, radius_m: float) -> RouteResponse:
    """ルートを生成

    Args:
        current_lat: 現在の緯度
        current_lng: 現在の経度
        radius_m: 半径 (メートル単位)

    Returns:
        RouteResponse: ルート情報
    """
    # 値オブジェクトに変換
    current_lat_vo = Latitude(value=current_lat)
    current_lng_vo = Longitude(value=current_lng)

    origin = f"{current_lat},{current_lng}"

    # ランダムな目的地を生成
    destination_lat, destination_lng = generate_random_point(
        current_lat_vo, current_lng_vo, radius_m
    )
    destination = f"{destination_lat.to_float()},{destination_lng.to_float()}"

    # Directions APIからルート情報を取得(キャッシュ付き)
    data = fetch_directions(origin, destination)

    # ルートの座標を取得
    route_coordinates = []
    for step in data["routes"][0]["legs"][0]["steps"]:
        # ステップごとの詳細なルート情報を取得
        route_coordinates.extend(decode_polyline(step["polyline"]["points"]))

    # 中心の座標を設定(folium用にfloatのタプルに変換)
    center_coord = route_coordinates[len(route_coordinates) // 2]
    center = (center_coord[0].to_float(), center_coord[1].to_float())

    # 出発地点の座標を取得
    departure_lat = current_lat_vo
    departure_lng = current_lng_vo

    # 中間地点の座標を計算
    midpoint_index = len(route_coordinates) // 2
    midpoint_lat, midpoint_lng = route_coordinates[midpoint_index]

    # マップを作成
    m = folium.Map(location=center, zoom_start=16)

    # ルートのポリラインを追加(folium用にfloatのタプルのリストに変換)
    route_coordinates_float = [(lat.to_float(), lng.to_float()) for lat, lng in route_coordinates]
    folium.PolyLine(locations=route_coordinates_float, color="blue", weight=2.5, opacity=1).add_to(
        m
    )

    # 出発地点にマーカーを追加
    folium.Marker(
        location=(departure_lat.to_float(), departure_lng.to_float()),
        popup="Departure",
        icon=folium.Icon(color="green"),
    ).add_to(m)

    # 目的地にマーカーを追加
    folium.Marker(
        location=(destination_lat.to_float(), destination_lng.to_float()),
        popup="Destination",
        icon=folium.Icon(color="red"),
    ).add_to(m)

    # 中間地点にマーカーを追加
    folium.Marker(
        location=(midpoint_lat.to_float(), midpoint_lng.to_float()),
        popup="Midpoint",
        icon=folium.Icon(color="orange"),
    ).add_to(m)

    # 中間地点の画像とメタデータの緯度経度取得
    midpoint_image_data = None
    midpoint_image_lat = None
    midpoint_image_lng = None
    try:
        photo_data = get_street_view_image_data(midpoint_lat, midpoint_lng, "600x300")
        midpoint_image_data = photo_data.image_data
        midpoint_image_lat = photo_data.metadata_latitude
        midpoint_image_lng = photo_data.metadata_longitude
    except HTTPException:
        # Street View画像が取得できない場合は画像情報なしで続行
        logger.warning(
            f"Failed to fetch Street View image for midpoint at "
            f"{midpoint_lat.to_float()}, {midpoint_lng.to_float()}"
        )

    # 最終地点の画像とメタデータの緯度経度取得
    destination_image_data = None
    destination_image_lat = None
    destination_image_lng = None
    try:
        destination_photo_data = get_street_view_image_data(
            destination_lat.to_float(), destination_lng.to_float(), "600x300"
        )
        destination_image_data = destination_photo_data.image_data
        destination_image_lat = destination_photo_data.metadata_latitude
        destination_image_lng = destination_photo_data.metadata_longitude
    except HTTPException:
        # Street View画像が取得できない場合は画像情報なしで続行
        logger.warning(
            f"Failed to fetch Street View image for destination at "
            f"{destination_lat.to_float()}, {destination_lng.to_float()}"
        )

    # 出力用のデータを準備
    return RouteResponse(
        departure=Point(latitude=departure_lat, longitude=departure_lng),
        destination=MidPoint(
            latitude=destination_lat,
            longitude=destination_lng,
            image_latitude=destination_image_lat,
            image_longitude=destination_image_lng,
            image_utf8=destination_image_data,
        ),
        midpoints=[
            MidPoint(
                latitude=midpoint_lat,
                longitude=midpoint_lng,
                image_latitude=midpoint_image_lat,
                image_longitude=midpoint_image_lng,
                image_utf8=midpoint_image_data,
            )
        ],
        overview_polyline=data["routes"][0]["overview_polyline"]["points"],
    )
