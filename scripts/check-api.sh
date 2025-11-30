#!/bin/bash
set -euo pipefail

# プロジェクトルートに移動（このスクリプトはプロジェクトルートから実行されることを想定）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# OpenAPIスキーマを生成
cd backend && uv run python scripts/generate_openapi.py
cd "$PROJECT_ROOT"

# 一時ディレクトリに再生成して差分をチェック
# 既存のファイルを削除してから再生成（テストファイルのスキップを防ぐため）
rm -rf /tmp/snampo-api-check
mkdir -p /tmp/snampo-api-check
docker run --rm \
  -v "${PROJECT_ROOT}:/local" \
  -v /tmp/snampo-api-check:/tmp/check \
  openapitools/openapi-generator-cli:v7.2.0 \
  generate \
  -i /local/backend/openapi.json \
  -g dart \
  -o /tmp/check/generated \
  -c /local/openapi-generator-config.yaml

# macOSとLinuxの両方で動作するように、rsyncを使って除外ファイルを除いて比較
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# 既存のファイルをコピー（除外ファイルを除く）
rsync -a --exclude='.dart_tool' --exclude='pubspec.lock' \
  packages/snampo_api/ "$TMP_DIR/existing/"

# 生成されたファイルをコピー（除外ファイルを除く）
rsync -a --exclude='.dart_tool' --exclude='pubspec.lock' \
  /tmp/snampo-api-check/generated/ "$TMP_DIR/generated/"

# 差分をチェック
if ! diff -r "$TMP_DIR/existing/" "$TMP_DIR/generated/" > /dev/null; then
  echo "Generated API client is out of date. Please run: mise run generate-api"
  exit 1
fi

echo "API client is up to date."
