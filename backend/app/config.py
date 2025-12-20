"""設定管理モジュール

環境変数の読み込み、定数の定義、APIキーの管理を行います。
"""

import os

from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Request timeout constant (in seconds)
REQUEST_TIMEOUT_SECONDS = 15

# Cache TTL constant (in seconds) - 1 hour
CACHE_TTL_SECONDS = 3600

# Get Google API key from environment variable
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError(
        "GOOGLE_API_KEY environment variable is not set. "
        "Please set it in your .env file or environment variables."
    )
