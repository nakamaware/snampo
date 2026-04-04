#!/bin/bash
set -euo pipefail

# プロジェクトルートに移動（このスクリプトはプロジェクトルートから実行されることを想定）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# OpenAPIスキーマを生成
cd backend && uv run python scripts/generate_openapi.py
cd "$PROJECT_ROOT"

# 既存の生成物を削除して再生成
rm -rf packages/snampo_api
MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' docker run --rm \
  -v "${PROJECT_ROOT}:/local" \
  openapitools/openapi-generator-cli:v7.2.0 \
  generate \
  -i /local/backend/openapi.json \
  -g dart \
  -o /local/packages/snampo_api \
  -c /local/openapi-generator-config.yaml

echo "API client generated successfully."
