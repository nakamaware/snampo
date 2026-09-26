# 協力プレイの手作業の手順

協力プレイ (みんなで) のインフラは dev と prod の両方に構成する。

- Firebase: `terraform/modules/gcp/firebase` (サブモジュール) を `terraform/modules/common/main.tf` から呼び出す
- Cloud Storage のバケット: `terraform/modules/common/main.tf` の `coop_bucket` (公開モジュール `terraform-google-modules/cloud-storage`)

Terraform で管理できないものと、Terraform の結果をアプリに反映する作業をここにまとめる。

## 1. Terraform の apply

`terraform/modules` 配下を変更すると、main へのマージ後に CD (`terraform-cd.yml`) が dev と prod の両方に apply する。

dev の CD が #257 (budget のエラー) で失敗している間も、Firebase のリソースは budget 以外として apply される。
それでも失敗した場合は、ローカルから apply する (Owner 権限が必要)。

```bash
gcloud auth application-default login
cd terraform/env/dev
terraform init
terraform plan
terraform apply
```

### Android の署名証明書 (Play Integrity 用)

Play Integrity を使うには、Firebase の Android アプリに署名証明書の SHA-256 を登録する。
`terraform/env/prod/main.tf` のモジュール呼び出しに `firebase_android_sha256_hashes` を追加する。

```hcl
module "snampo_prod" {
  # ...
  firebase_android_sha256_hashes = ["<SHA-256 (コロンなし、小文字)>"]
}
```

注意: Play Console を使っていない現状では、prod の Android ビルドの協力プレイは動かない (Play 経由でインストールしたアプリが前提のため)。

## 2. Firebase の設定 (`FIREBASE_*`) を登録する

API キーとアプリ ID は公開値だが、念のため secret として扱う。リポジトリには置かず、ビルド時に dart-define で渡す。
プロジェクト ID とバケット名は `frontend/lib/core/firebase/firebase_options.dart` に置く。
そのプラットフォームの値が空の間、アプリは Firebase を初期化せず、協力プレイだけを使えない状態にする (ソロは遊べる)。

apply 後、Terraform の output から値を取り出す (出力をそのまま `.env` の形で使える)。

```bash
cd terraform/env/dev   # prod なら terraform/env/prod
terraform output -json firebase_options | jq -r '
  "FIREBASE_ANDROID_API_KEY=\(.android_config_json | fromjson | .client[0].api_key[0].current_key)",
  "FIREBASE_ANDROID_APP_ID=\(.android_app_id)",
  "FIREBASE_IOS_API_KEY=\(.ios_config_plist | capture("<key>API_KEY</key>\\s*<string>(?<k>[^<]+)</string>").k)",
  "FIREBASE_IOS_APP_ID=\(.ios_app_id)",
  "FIREBASE_MESSAGING_SENDER_ID=\(.messaging_sender_id)"'
```

取り出した値を、次の場所に登録する。

| 登録先 | 登録する値 |
|---|---|
| ローカルの `frontend/.env` | 5 つすべて |
| GitHub の Environment `dev` の Secrets (`cd-frontend.yml` の Android の APK のビルド) | `FIREBASE_ANDROID_API_KEY`、`FIREBASE_ANDROID_APP_ID`、`FIREBASE_MESSAGING_SENDER_ID` |
| Codemagic の環境変数グループ `ios-dev` (Secure にする) (iOS のビルド) | `FIREBASE_IOS_API_KEY`、`FIREBASE_IOS_APP_ID`、`FIREBASE_MESSAGING_SENDER_ID` |

prod のビルドの仕組みはまだないため、prod の値は prod のビルドを用意するときに同じように登録する。

`google-services.json` と `GoogleService-Info.plist` はアプリに置かない。

## 3. App Check のデバッグトークンを登録する (dev)

dev ビルドは App Check の Debug provider を使う。デバッグトークンは端末ごとに生成され、コードやリポジトリには置かない。
友人向けの dev APK や TestFlight も、端末ごとにこの手順で登録する。

1. 端末でアプリを開き、ホーム右上の歯車 (設定画面) を開く
2. 「App Check デバッグトークン」をコピーするか、共有で管理者に送る
   - トークンは起動時のログにも `[AppCheck] debug token: ...` として出力される
3. 管理者が [Firebase コンソール](https://console.firebase.google.com/) で dev のプロジェクト (`snampo-480404`) を開く
4. 「App Check」→「アプリ」→ 対象のアプリ (Android / iOS) のメニュー →「デバッグトークンを管理」
5. 「デバッグトークンを追加」で、名前 (例: 「たろうの Pixel」) とトークンを登録する
6. 端末で「みんなで」を開き直す (エラー画面なら「再試行」)

## 4. App Attest (prod の iOS)

- Apple Developer の Certificates, Identifiers & Profiles で、App ID `com.nakamaware.snampo` の App Attest capability を有効にする (必要な場合)
- entitlement (`com.apple.developer.devicecheck.appattest-environment`) は `frontend/ios/Runner/Runner.entitlements` に追加済み
- DeviceCheck へのフォールバックを使う場合は、Firebase コンソールの App Check で DeviceCheck の秘密鍵を登録する

## 5. 料金の確認

Storage を使うため Blaze プランが前提。予算アラートは既存のもの (#257 の修正後に機能する) を使う。

- 1 ゲームあたりの Firestore 読み取り量の目安は、5 人・26 スポットの最大規模で約 500 (無料枠は 1 日 50,000)
- Cloud Storage のバケットは Always Free の対象リージョン (`us-central1`) に作り、7 日で削除する
- 料金表は定期的に再確認する: [Firebase Pricing](https://firebase.google.com/pricing/)

## 6. Security Rules のテスト

Node.js 22 と Java 21 は `firebase/.mise.toml` で管理している。`firebase/` に入ると、ルートの Java 17 ではなく Java 21 が使われる。

```bash
cd firebase
mise trust   # 初回のみ
mise install
npm ci
npm test
```
