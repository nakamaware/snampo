#!/bin/bash
set -euo pipefail

# frontend/.env の各行を --dart-define にして flutter を実行する
# VS Code の Dart 拡張の customTool から flutter の代わりに呼ばれる
# .env は 1Password の名前付きパイプなので --dart-define-from-file では読めない
# 通常の .env ファイルでも同じ結果になるよう、解釈は flutter の --dart-define-from-file に合わせている
# (flutter_tools の DotEnvRegex / convertEnvFileToJsonRaw)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../frontend/.env"

# プロセス置換だと読み取り失敗が set -e に伝わらないので、先に変数へ読み込んで終了状態を確認する
if ! env_content="$(cat "$ENV_FILE")"; then
  echo "error: $ENV_FILE を読み取れませんでした" >&2
  exit 1
fi

ws='[[:space:]]'
key_value_re="^([a-zA-Z_][a-zA-Z0-9_]*)$ws*=$ws*(.*)$"
multi_line_re="^[a-zA-Z_][a-zA-Z0-9_]*$ws*=$ws*\"\"\""
comment_re="$ws*(#.*)?$"
double_quoted_re="^\"(.*)\"$comment_re"
single_quoted_re="^'(.*)'$comment_re"
back_quoted_re="^\`(.*)\`$comment_re"
unquoted_re="^([^#[:space:]]*)$ws*(#.*)?$"

defines=()
while IFS= read -r line || [ -n "$line" ]; do
  # 前後の空白 (CRLF の \r を含む) を取り除き、空行とコメント行を飛ばす
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"
  if [ -z "$line" ] || [[ "$line" == \#* ]]; then
    continue
  fi

  if [[ "$line" =~ $multi_line_re ]]; then
    echo "error: 複数行の値には対応していません: $line" >&2
    exit 1
  fi
  if ! [[ "$line" =~ $key_value_re ]]; then
    echo "error: $ENV_FILE の行を解釈できません: $line" >&2
    exit 1
  fi
  key="${BASH_REMATCH[1]}"
  value="${BASH_REMATCH[2]}"

  # 囲んでいる引用符と行末コメントを取り除く
  if [[ "$value" =~ $double_quoted_re ]] || [[ "$value" =~ $single_quoted_re ]] ||
    [[ "$value" =~ $back_quoted_re ]] || [[ "$value" =~ $unquoted_re ]]; then
    value="${BASH_REMATCH[1]}"
  fi

  defines+=("--dart-define=$key=$value")
done <<< "$env_content"

if [ "${#defines[@]}" -eq 0 ]; then
  echo "error: $ENV_FILE に定義がありません" >&2
  exit 1
fi

exec flutter "$@" "${defines[@]}"
