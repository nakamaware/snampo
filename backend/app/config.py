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

# キャッシュTTL定数 (秒) - 1時間
CACHE_TTL_SECONDS = 3600

# 環境変数からGoogle APIキーを取得
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError(
        "GOOGLE_API_KEY環境変数が設定されていません。.envファイルまたは環境変数に設定してください。"
    )
