#!/bin/bash
set -euo pipefail

# scripts/flutter-with-env.sh のテスト
# 一時ディレクトリにスクリプトと frontend/.env を置き、偽の flutter で渡された引数を確かめる
# 期待値は flutter の --dart-define-from-file が .env を解釈した結果に合わせている
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$WORK_DIR/scripts" "$WORK_DIR/frontend" "$WORK_DIR/bin"
cp "$SCRIPT_DIR/flutter-with-env.sh" "$WORK_DIR/scripts/"
ENV_FILE="$WORK_DIR/frontend/.env"

# 偽の flutter: 受け取った引数を1行ずつ出力する
cat > "$WORK_DIR/bin/flutter" << 'EOF'
#!/bin/bash
printf '%s\n' "$@"
EOF
chmod +x "$WORK_DIR/bin/flutter"

failures=0
output=""
status=0

run_wrapper() {
  status=0
  output="$(PATH="$WORK_DIR/bin:$PATH" bash "$WORK_DIR/scripts/flutter-with-env.sh" "$@" 2>&1)" || status=$?
}

# $1: テスト名, $2: .env の中身, $3: 期待する flutter の引数（改行区切り）
expect_args() {
  printf '%b' "$2" > "$ENV_FILE"
  run_wrapper run
  if [ "$status" -eq 0 ] && [ "$output" == "$(printf 'run\n%b' "$3")" ]; then
    echo "ok: $1"
  else
    echo "FAIL: $1"
    echo "  status: $status"
    echo "  expected:"
    printf 'run\n%b\n' "$3" | sed 's/^/    /'
    echo "  actual:"
    printf '%s\n' "$output" | sed 's/^/    /'
    failures=$((failures + 1))
  fi
}

# $1: テスト名, $2: .env の中身（省略時は .env を置かない）
expect_failure() {
  rm -f "$ENV_FILE"
  if [ "$#" -ge 2 ]; then
    printf '%b' "$2" > "$ENV_FILE"
  fi
  run_wrapper run
  if [ "$status" -ne 0 ] && [[ "$output" != *"--dart-define"* ]]; then
    echo "ok: $1"
  else
    echo "FAIL: $1 (flutter が起動した、または終了コードが 0)"
    printf '%s\n' "$output" | sed 's/^/    /'
    failures=$((failures + 1))
  fi
}

expect_args "基本の KEY=value" \
  'FLAVOR=dev\nAPI_BASE_URL=http://10.0.2.2:8000\n' \
  '--dart-define=FLAVOR=dev\n--dart-define=API_BASE_URL=http://10.0.2.2:8000'
expect_args "前後と = まわりの空白" \
  '  KEY = value  \n' \
  '--dart-define=KEY=value'
# shellcheck disable=SC2016 # バッククォートは .env の中身としてそのまま書く
expect_args "引用符で囲んだ値" \
  'A="quoted value" # comment\nB='"'"'single'"'"'\nC=`back`\nD="a"b"\n' \
  '--dart-define=A=quoted value\n--dart-define=B=single\n--dart-define=C=back\n--dart-define=D=a"b'
expect_args "行末コメントと # を含む値" \
  'A=value # comment\nB=a#b\n' \
  '--dart-define=A=value\n--dart-define=B=a'
expect_args "引用符なしで空白を含む値はそのまま" \
  'KEY=foo bar\n' \
  '--dart-define=KEY=foo bar'
expect_args "空の値、小文字と数字のキー、= を含む値" \
  'EMPTY=\nlower_key1=x\nURL=a=b=c\n' \
  '--dart-define=EMPTY=\n--dart-define=lower_key1=x\n--dart-define=URL=a=b=c'
expect_args "CRLF の改行" \
  'A=1\r\nB=2\r\n' \
  '--dart-define=A=1\n--dart-define=B=2'
expect_args "コメント行と空行を飛ばす" \
  '# comment\n\n  # indented comment\nA=1\n' \
  '--dart-define=A=1'
expect_args "最終行に改行がない" \
  'A=1\nB=2' \
  '--dart-define=A=1\n--dart-define=B=2'

# 呼び出し元の引数は定義より前にそのまま渡す
printf 'A=1\n' > "$ENV_FILE"
run_wrapper run -d "my device"
if [ "$status" -eq 0 ] && [ "$output" == "$(printf 'run\n-d\nmy device\n--dart-define=A=1')" ]; then
  echo "ok: 呼び出し元の引数を保つ"
else
  echo "FAIL: 呼び出し元の引数を保つ"
  printf '%s\n' "$output" | sed 's/^/    /'
  failures=$((failures + 1))
fi

# 1Password と同じく名前付きパイプから読む
rm -f "$ENV_FILE"
mkfifo "$ENV_FILE"
printf 'A="from pipe"\n' > "$ENV_FILE" &
run_wrapper run
wait
if [ "$status" -eq 0 ] && [ "$output" == "$(printf 'run\n--dart-define=A=from pipe')" ]; then
  echo "ok: 名前付きパイプから読む"
else
  echo "FAIL: 名前付きパイプから読む"
  printf '%s\n' "$output" | sed 's/^/    /'
  failures=$((failures + 1))
fi

expect_failure ".env がない"
expect_failure "定義が1つもない" '# only comment\n\n'
expect_failure "解釈できない行" 'export FOO=bar\n'
expect_failure "複数行の値" 'KEY="""\nline\n"""\n'

if [ "$failures" -gt 0 ]; then
  echo "$failures 件失敗しました" >&2
  exit 1
fi
echo "すべて成功しました"
