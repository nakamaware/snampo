#!/usr/bin/env python3
"""OpenAPIスキーマを生成するスクリプト

FastAPIアプリからOpenAPIスキーマ(JSON)を生成し、backend/openapi.jsonに出力します。
"""

import json
import os
import sys
from pathlib import Path

# プロジェクトルートを取得
project_root = Path(__file__).parent.parent.parent
backend_dir = project_root / "backend"

# バックエンドディレクトリをパスに追加
sys.path.insert(0, str(backend_dir))

# OpenAPIスキーマ生成時には実際のAPIキーは不要なので、ダミー値を設定
# これにより、main.pyのインポート時の環境変数チェックをパスできる
if "GOOGLE_API_KEY" not in os.environ:
    os.environ["GOOGLE_API_KEY"] = "dummy-key-for-openapi-generation"

# FastAPIアプリをインポート
from app.main import app  # noqa: E402

# OpenAPIスキーマを取得
openapi_schema = app.openapi()

# 出力先のパス
output_path = backend_dir / "openapi.json"

# JSONファイルに書き込み
with output_path.open("w", encoding="utf-8") as f:
    json.dump(openapi_schema, f, indent=2, ensure_ascii=False)
    f.write("\n")  # ファイル末尾に改行を追加

print(f"OpenAPI schema generated successfully: {output_path}")
