#!/bin/bash
set -euo pipefail

# frontend/.env の各行を --dart-define にして flutter を実行する
# VS Code の Dart 拡張の customTool から flutter の代わりに呼ばれる
# .env は 1Password の名前付きパイプなので --dart-define-from-file では読めない
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../frontend/.env"

# プロセス置換だと読み取り失敗が set -e に伝わらないので、先に変数へ読み込んで終了状態を確認する
# grep は一致なしでも 1 を返すので、2 以上（読み取り失敗）のときだけ中止する
status=0
env_lines="$(grep -E '^[A-Z_]+=' "$ENV_FILE")" || status=$?
if [ "$status" -ge 2 ]; then
  echo "error: $ENV_FILE を読み取れませんでした" >&2
  exit 1
fi
if [ -z "$env_lines" ]; then
  echo "error: $ENV_FILE に定義がありません" >&2
  exit 1
fi

defines=()
while IFS= read -r line; do
  defines+=("--dart-define=$line")
done <<< "$env_lines"

exec flutter "$@" "${defines[@]}"
