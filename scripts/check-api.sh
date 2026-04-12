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
HOST_CHECK_DIR="$PROJECT_ROOT/.tmp/snampo-api-check"
rm -rf "$HOST_CHECK_DIR"
mkdir -p "$HOST_CHECK_DIR"
MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' docker run --rm \
  -v "${PROJECT_ROOT}:/local" \
  -v "${HOST_CHECK_DIR}:/tmp/check" \
  openapitools/openapi-generator-cli:v7.2.0 \
  generate \
  -i /local/backend/openapi.json \
  -g dart \
  -o /tmp/check/generated \
  -c /local/openapi-generator-config.yaml

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR" "$HOST_CHECK_DIR" >/dev/null 2>&1 || true' EXIT

# 既存のファイルをコピー (比較不要なファイルは後で除外)
mkdir -p "$TMP_DIR/existing" "$TMP_DIR/generated"
cp -R packages/snampo_api/. "$TMP_DIR/existing/"

# 生成されたファイルをコピー (比較不要なファイルは後で除外)
cp -R "$HOST_CHECK_DIR/generated/." "$TMP_DIR/generated/"

# 比較不要なファイルを除外
rm -rf "$TMP_DIR/existing/.dart_tool" "$TMP_DIR/generated/.dart_tool"
rm -f "$TMP_DIR/existing/pubspec.lock" "$TMP_DIR/generated/pubspec.lock"

# 差分をチェック
# Windows では checkout 済みファイルが CRLF になりうるため、
# 改行コード差分は無視して中身だけを比較する
if ! git diff --no-index --ignore-cr-at-eol --quiet \
  "$TMP_DIR/existing" "$TMP_DIR/generated" > /dev/null 2>&1; then
  echo "Generated API client is out of date. Please run: mise run generate-api"
  exit 1
fi

echo "API client is up to date."
