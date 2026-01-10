"""設定管理モジュール

環境変数の読み込み、定数の定義、APIキーの管理を行います。
"""

import os

from dotenv import load_dotenv

# .envファイルから環境変数を読み込む
load_dotenv()

# リクエストタイムアウト定数 (秒)
REQUEST_TIMEOUT_SECONDS = 15

# ルート生成のリトライ回数
ROUTE_GENERATION_MAX_RETRY_COUNT = 3

# キャッシュTTL定数 (秒) - 24時間
CACHE_TTL_SECONDS = 86400

# ランドマーク検索の設定
LANDMARK_SEARCH_TARGET_COUNT = 5  # 目標件数
LANDMARK_SEARCH_MAX_CALLS = 8  # 最大API呼び出し回数
LANDMARK_DISTANCE_TOLERANCE_PERCENT = 15.0  # 許容誤差 (%)
LANDMARK_SEARCH_TIME_BUDGET_MS = 3000  # タイムアウト予算 (ミリ秒)
MIN_SEARCH_RADIUS_M = 50  # Google Maps Nearby Search APIの最小検索半径 (メートル)

# ランドマーク検索対象のタイプ
LANDMARK_INCLUDED_TYPES = [
    # 文化
    "cultural_landmark",
    "historical_place",
    "monument",
    "museum",
    "sculpture",
    # 教育
    "library",
    "university",
    # エンターテイメント/レクリエーション
    "amusement_center",
    "amusement_park",
    "aquarium",
    "casino",
    "garden",
    "park",
    "tourist_attraction",
    "zoo",
    # 政府、行政機関
    "government_office",
    "local_government_office",
    # 自然地物
    "beach",
    # ショッピング
    "shopping_mall",
    # 交通
    "airport",
    "airstrip",
    "ferry_terminal",
    "international_airport",
    "light_rail_station",
    "subway_station",
    "train_station",
]

# 環境変数からGoogle APIキーを取得
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError(
        "GOOGLE_API_KEY環境変数が設定されていません。.envファイルまたは環境変数に設定してください。"
    )
