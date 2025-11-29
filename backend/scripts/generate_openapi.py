#!/usr/bin/env python3
"""OpenAPIスキーマを生成するスクリプト

FastAPIアプリからOpenAPIスキーマ(JSON)を生成し、backend/openapi.jsonに出力します。
"""

import json
import sys
from pathlib import Path

# プロジェクトルートを取得
project_root = Path(__file__).parent.parent.parent
backend_dir = project_root / "backend"

# バックエンドディレクトリをパスに追加
sys.path.insert(0, str(backend_dir))

# FastAPIアプリをインポート
from app.main import app  # noqa: E402

# OpenAPIスキーマを取得
openapi_schema = app.openapi()

# 出力先のパス
output_path = backend_dir / "openapi.json"

# JSONファイルに書き込み
with output_path.open("w", encoding="utf-8") as f:
    json.dump(openapi_schema, f, indent=2, ensure_ascii=False)

print(f"OpenAPI schema generated successfully: {output_path}")
