# Snampo

Snampoプロジェクトのリポジトリです。

## プロジェクト構成

- `frontend/`: Flutterアプリケーション
- `backend/`: FastAPIバックエンド

## 環境構築

### 必要なツール

- [mise](https://mise.jdx.dev/) - バージョン管理ツールとタスクランナー
- Android Studio（Android開発用）
- [uv](https://github.com/astral-sh/uv) - Pythonパッケージマネージャー（バックエンド用）
- [pre-commit](https://pre-commit.com/) - Gitフック管理ツール（コード品質チェック用）

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

   参考: [mise ドキュメント](https://mise.jdx.dev/getting-started.html)

2. **uvのインストール**（未インストールの場合）

   ```bash
   # macOS / Linux
   curl -LsSf https://astral.sh/uv/install.sh | sh

   # または Homebrew
   brew install uv

   # Windows
   powershell -ExecutionPolicy ByPass -c \
     "irm https://astral.sh/uv/install.ps1 | iex"
   ```

   参考: [uv インストール](https://github.com/astral-sh/uv#installation)

3. **プロジェクトのクローン**

   ```bash
   git clone <repository-url>
   cd snampo
   ```

4. **VS Code拡張機能のインストール**（推奨）

   VS Codeを使用する場合、推奨される拡張機能をインストールすることをお勧めします。

   **推奨拡張機能の一覧は `.vscode/extensions.json` を参照してください。**

   拡張機能のインストール方法：

   - VS Codeでプロジェクトを開くと、推奨拡張機能の通知が表示されます。「インストール」をクリックして一括インストールできます
   - または、VS Codeのコマンドパレット（Cmd+Shift+P / Ctrl+Shift+P）から「Extensions: Show Recommended Extensions」を選択して、推奨拡張機能を確認・インストールできます
   - 手動でインストールする場合は、VS Codeの拡張機能タブから各拡張機能を検索してインストールすることもできます

5. **miseでツールをインストール**

   ```bash
   # 初回のみ、設定ファイルを信頼する必要があります
   mise trust

   # ツールをインストール
   mise install
   ```

   これにより、プロジェクトに必要なFlutterとJavaのバージョンが自動的にインストールされます。

6. **依存関係のインストール**

   ```bash
   # プロジェクトルートから実行（フロントエンドとバックエンドの両方の依存関係をインストール）
   mise run setup
   ```

7. **Android SDKの設定**

   Android Studioをインストールするか、Android SDKを手動で設定してください。

   Android SDK Platform 36が必要です。

8. **secret.propertiesの設定**（フロントエンド）

   Google Maps API キーを設定するために、
   `frontend/android/secret.properties.example` をコピーして
   `frontend/android/secret.properties` を作成し、API キーを設定してください。

   ```bash
   cd frontend/android
   cp secret.properties.example secret.properties
   ```

   その後、`frontend/android/secret.properties` を開いて
   `YOUR_GOOGLE_MAPS_API_KEY_HERE` を実際の Google Maps API キーに
   置き換えてください。

9. **環境変数の設定**（バックエンド）

   Google Maps API キーを設定するために、`backend/.env.example`をコピーして
   `backend/.env`ファイルを作成してください。

   ```bash
   cd backend
   cp .env.example .env
   ```

   その後、`backend/.env`ファイルを開いて、
   `your_google_maps_api_key_here`を実際のGoogle Maps APIキーに
   置き換えてください。

   ```bash
   GOOGLE_API_KEY=your_google_maps_api_key_here
   ```

#### 使用しているツールバージョン

- **Flutter**: 3.32.0
- **Java**: 17
- **Gradle**: 8.10.2
- **Kotlin**: 2.0.21
- **Android Gradle Plugin**: 8.8.0
- **Android SDK**: 36 (compileSdkVersion, targetSdkVersion)
- **Python**: 3.13
- **FastAPI**: >=0.104.0
- **Uvicorn**: >=0.24.0
- **Requests**: >=2.31.0
- **Folium**: >=0.15.0

---

## タスクランナー

このプロジェクトでは、[mise](https://mise.jdx.dev/)のタスク機能を使用して、フロントエンドとバックエンドのコマンドを統合管理しています。プロジェクトルートの`.mise.toml`にタスクが定義されています。

### 利用可能なタスク

> **Note:** VS Codeを使用している場合、以下の機能は自動化されています：
>
> - `flutter pub get` - `pubspec.yaml`保存時に自動実行
> - `dart format` - 保存時フォーマット（設定により自動）
> - `flutter analyze` - リアルタイムでエディタに表示
> - `ruff format` / `ruff check` - Python拡張機能で自動化可能

#### フロントエンドタスク

```bash
# 開発サーバーを起動（VS Codeのデバッグ実行でも可能）
mise run frontend:dev

# 依存関係をインストール（VS Codeではpubspec.yaml保存時に自動実行）
mise run frontend:setup
```

#### バックエンドタスク

```bash
# 開発サーバーを起動
mise run backend:dev

# 依存関係をインストール
mise run backend:setup
```

#### 統合タスク

```bash
# フロントエンドとバックエンドを同時に起動
mise run dev

# プロジェクトの初期セットアップ（依存関係のインストールとpre-commitのセットアップ）
mise run setup
```

### タスク一覧の確認

利用可能なタスクの一覧を確認するには：

```bash
mise tasks
```

### Dockerを使用した起動（バックエンド）

Dockerを使用する場合：

```bash
cd backend
# Docker Composeを使用
docker-compose up --build

# または、Dockerfileから直接ビルド
docker build -t snampo-backend .
docker run -p 80:80 --env-file .env snampo-backend
```
