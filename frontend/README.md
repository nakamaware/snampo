# snampo

A new Flutter project.

## セットアップ

### 必要なツール

- [mise](https://mise.jdx.dev/) - バージョン管理ツール
- Android Studio（Android開発用）

### セットアップ手順

1. **miseのインストール**（未インストールの場合）

   ```bash
   # macOS / Linux
   curl https://mise.run | sh
   
   # または Homebrew
   brew install mise

   # Windows
   winget install jdx.mise
   ```

   - 参考: [mise ドキュメント](https://mise.jdx.dev/getting-started.html)

2. **プロジェクトのクローン**

   ```bash
   git clone <repository-url>
   cd frontend
   ```

3. **miseでツールをインストール**

   ```bash
   # 初回のみ、設定ファイルを信頼する必要があります
   mise trust
   
   # ツールをインストール
   mise install
   ```

   これにより、プロジェクトに必要なFlutterとJavaのバージョンが自動的にインストールされます。

4. **依存関係のインストール**

   ```bash
   flutter pub get
   ```

5. **Android SDKの設定**

   Android Studioをインストールするか、Android SDKを手動で設定してください。

   Android SDK Platform 36が必要です。

6. **secret.propertiesの設定**

   Google Maps API キーを設定するために、`secret.properties.example` をコピーして
   `secret.properties` を作成し、API キーを設定してください。

   ```bash
   cd android
   cp secret.properties.example secret.properties
   ```

   その後、`android/secret.properties` を開いて
   `YOUR_GOOGLE_MAPS_API_KEY_HERE` を実際の Google Maps API キーに置き換えてください。

7. **アプリの実行**

   ```bash
   flutter run
   ```

## 使用しているツールバージョン

- **Flutter**: 3.32.0
- **Java**: 17
- **Gradle**: 8.10.2
- **Kotlin**: 2.0.21
- **Android Gradle Plugin**: 8.8.0
- **Android SDK**: 36 (compileSdkVersion, targetSdkVersion)

## 開発

### ホットリロード

アプリ実行中に `r` キーを押すとホットリロードが実行されます。

### ビルド

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

## トラブルシューティング

### miseがツールを認識しない場合

```bash
# miseのシェル統合を確認
mise activate

# シェルを再起動するか、以下を実行
eval "$(mise activate zsh)"  # zshの場合
eval "$(mise activate bash)" # bashの場合
```

### Flutterのパスが正しく設定されない場合

```bash
# Flutterのパスを確認
which flutter

# miseでFlutterを再インストール
mise uninstall flutter
mise install
```
