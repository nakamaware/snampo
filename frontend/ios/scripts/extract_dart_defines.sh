#!/bin/bash

# 環境変数をDart defineに変換するスクリプト
# 参考: https://zenn.dev/altiveinc/articles/separating-environments-in-flutter

# Dart defineを書き出すファイルパスを指定する
OUTPUT_FILE="${SRCROOT}/Flutter/Dart-Defines.xcconfig"
# Dart defineの中身を変更した時に古いプロパティが残らないように、初めにファイルを空にする
: > $OUTPUT_FILE

# Info.plistのパス
INFO_PLIST="${SRCROOT}/Runner/Info.plist"

# Dart defineをデコードする
function decode_url() { echo "${*}" | base64 --decode; }

# 環境変数の値を取得する関数
function get_env_value() {
    local key=$1
    local value=""
    IFS=',' read -r -a define_items <<<"$DART_DEFINES"
    for index in "${!define_items[@]}"
    do
        item=$(decode_url "${define_items[$index]}")
        if [[ $item == "$key="* ]]; then
            value="${item#*=}"
            break
        fi
    done
    echo "$value"
}

IFS=',' read -r -a define_items <<<"$DART_DEFINES"

for index in "${!define_items[@]}"
do
    item=$(decode_url "${define_items[$index]}")
    # Dartの定義にはFlutter側で自動定義された項目も含まれる
    # しかし、それらの定義を書き出してしまうとエラーによりビルドができなくなるので、
    # flutterやFLUTTERで始まる項目は出力しないようにする
    lowercase_item=$(echo "$item" | tr '[:upper:]' '[:lower:]')
    if [[ $lowercase_item != flutter* ]]; then
        echo "$item" >> "$OUTPUT_FILE"
    fi
done

# Info.plistにGOOGLE_MAP_API_KEYを書き込む
if [ -f "$INFO_PLIST" ]; then
    GOOGLE_MAP_API_KEY=$(get_env_value "GOOGLE_MAP_API_KEY")
    if [ -n "$GOOGLE_MAP_API_KEY" ]; then
        # plutilを使用してInfo.plistを更新
        /usr/libexec/PlistBuddy -c "Set :GoogleMapsApiKey $GOOGLE_MAP_API_KEY" "$INFO_PLIST" 2>/dev/null || \
        plutil -replace GoogleMapsApiKey -string "$GOOGLE_MAP_API_KEY" "$INFO_PLIST" 2>/dev/null || \
        echo "Warning: Could not update Info.plist with GOOGLE_MAP_API_KEY"
    fi
fi
