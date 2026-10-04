#!/bin/bash
set -euo pipefail

# frontend/.env の各行を --dart-define にして flutter を実行する
# VS Code の Dart 拡張の customTool から flutter の代わりに呼ばれる
# .env は 1Password の名前付きパイプなので --dart-define-from-file では読めない
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../frontend/.env"

defines=()
while IFS= read -r line; do
  defines+=("--dart-define=$line")
done < <(grep -E '^[A-Z_]+=' "$ENV_FILE")

exec flutter "$@" "${defines[@]}"
