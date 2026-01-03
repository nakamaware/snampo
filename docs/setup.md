# セットアップガイド

このドキュメントでは、スナんぽの開発環境を構築するための詳細な手順を説明します。

## 必要なツール

- [mise](https://mise.jdx.dev/) - バージョン管理ツールとタスクランナー
- Android Studio（Android開発用）
- [uv](https://github.com/astral-sh/uv) - Pythonパッケージマネージャー（バックエンド用）
- [pre-commit](https://pre-commit.com/) - Gitフック管理ツール（コード品質チェック用）
- [Docker](https://www.docker.com/) - APIクライアント生成用（OpenAPI Generatorの実行に必要）

## セットアップ手順

開発環境を構築するには、以下の手順に従ってください。

### 1. miseのインストール（未インストールの場合）

```bash
# macOS / Linux
curl https://mise.run | sh

# または Homebrew
brew install mise

# Windows
winget install jdx.mise
```

参考: [mise ドキュメント](https://mise.jdx.dev/getting-started.html)

### 2. uvのインストール（未インストールの場合）

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

### 3. Dockerのインストール（未インストールの場合）

APIクライアント生成にDockerが必要です。

```bash
# macOS / Linux
# Homebrewを使用する場合
brew install --cask docker

# または、Docker Desktopを公式サイトからダウンロード
# https://www.docker.com/products/docker-desktop/
```

Windowsの場合：
- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)を公式サイトからダウンロードしてインストール

参考: [Docker インストール](https://docs.docker.com/get-docker/)

### 4. プロジェクトのクローン

```bash
git clone https://github.com/nakamaware/snampo.git
cd snampo
```

### 5. VS Code拡張機能のインストール（推奨）

VS Codeを使用する場合、推奨される拡張機能をインストールすることをお勧めします。

**推奨拡張機能の一覧は `.vscode/extensions.json` を参照してください。**

拡張機能のインストール方法：

- VS Codeでプロジェクトを開くと、推奨拡張機能の通知が表示されます。「インストール」をクリックして一括インストールできます
- または、VS Codeのコマンドパレット（Cmd+Shift+P / Ctrl+Shift+P）から「Extensions: Show Recommended Extensions」を選択して、推奨拡張機能を確認・インストールできます
- 手動でインストールする場合は、VS Codeの拡張機能タブから各拡張機能を検索してインストールすることもできます

### 6. miseでツールをインストール

```bash
# 初回のみ、設定ファイルを信頼する必要があります
mise trust

# ツールをインストール
mise install
```

これにより、プロジェクトに必要なFlutterとJavaのバージョンが自動的にインストールされます。

### 7. 依存関係のインストール

```bash
# プロジェクトルートから実行（フロントエンドとバックエンドの両方の依存関係をインストール）
mise run setup
```

### 8. Android SDKの設定

Android Studioをインストールするか、Android SDKを手動で設定してください。

Android SDK Platform 36が必要です。

### 9. 環境変数の設定（フロントエンド）

`frontend/.env.example` をコピーして `frontend/.env` ファイルを作成し、API キーとAPIのベースURLを設定してください。

```bash
cd frontend
cp .env.example .env
```

`.env` ファイルを開いて、実際の値を設定します：

```dotenv
FLAVOR=dev
GOOGLE_MAP_API_KEY=your_google_maps_api_key_here
API_BASE_URL=your_api_base_url_here
```

API_BASE_URLは以下のように設定します：

- 開発環境 (Android): `http://10.0.2.2:8000` (ローカルBEのポートに置き換えてください)
- 開発環境 (iOS): `http://localhost:8000` (ローカルBEのポートに置き換えてください)
- 本番環境: `https://hoge-fuga.asia-northeast1.run.app` (本番BEのURLに置き換えてください)

**VS Code から実行する場合**: `.vscode/launch.json` で `--dart-define-from-file=.env` が設定されているため、自動的に読み込まれます。

**コマンドラインから実行する場合**:

```bash
cd frontend
flutter run --dart-define-from-file=.env
```

### 10. 環境変数の設定（バックエンド）

Google Maps API キーを設定するために、`backend/.env.example`をコピーして
`backend/.env`ファイルを作成してください。

```bash
cd backend
cp .env.example .env
```

その後、`backend/.env`ファイルを開いて、
`your_google_maps_api_key_here`を実際のGoogle Maps APIキーに
置き換えてください。

```dotenv
GOOGLE_API_KEY=your_google_maps_api_key_here
```

## 使用しているツールバージョン

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
# 依存関係をインストール（VS Codeではpubspec.yaml保存時に自動実行）
mise run frontend:setup
```

**フロントエンドの実行について：**

フロントエンドアプリの実行は、VS Codeのデバッグ機能を使用してください。`.vscode/launch.json`に設定されたデバッグ構成を使用して起動できます。

- VS Codeのデバッグパネル（Cmd+Shift+D / Ctrl+Shift+D）から「Flutter dev」または「Flutter prod」を選択して実行
- または、F5キーでデバッグを開始

バックエンドを同時に起動する場合は、`launch.json`の`preLaunchTask`に`backend:dev`を設定することで、デバッグ開始時に自動的にバックエンドが起動します。

#### バックエンドタスク

```bash
# 開発サーバーを起動
mise run backend:dev

# 依存関係をインストール
mise run backend:setup
```

#### 統合タスク

```bash
# プロジェクトの初期セットアップ（依存関係のインストールとpre-commitのセットアップ）
mise run setup

# OpenAPIスキーマからDart APIクライアントを生成
mise run generate-api

# 生成されたAPIクライアントが最新かチェック（pre-commit/CI/CD用）
mise run check-api
```

**フロントエンドとバックエンドの同時起動：**

VS Codeのデバッグ実行を使用する場合、`.vscode/launch.json`の`preLaunchTask`に`backend:dev`を設定することで、フロントエンドのデバッグ開始時に自動的にバックエンドが起動します。

バックエンドのみを起動する場合：

```bash
# バックエンド開発サーバーを起動
mise run backend:dev

# または、VS Codeのタスクから実行（.vscode/tasks.json）
# コマンドパレット（Cmd+Shift+P / Ctrl+Shift+P）から「Tasks: Run Task」→「backend:dev」を選択
```

### タスク一覧の確認

利用可能なタスクの一覧を確認するには：

```bash
mise tasks
```

## APIクライアントの生成

このプロジェクトでは、バックエンドのOpenAPIスキーマから自動的にDart APIクライアントを生成しています。

> **注意**: APIクライアントの生成にはDockerが必要です。事前にDockerをインストールしておいてください。

### APIクライアントの生成方法

```bash
# OpenAPIスキーマを生成し、Dart APIクライアントを生成
mise run generate-api
```

このコマンドは以下の処理を実行します：

1. バックエンドのOpenAPIスキーマ（`backend/openapi.json`）を生成
2. Dockerコンテナ内でOpenAPI Generatorを実行してDart APIクライアント（`packages/snampo_api`）を生成

生成されたAPIクライアントは、フロントエンドの`pubspec.yaml`で依存関係として参照されています。

### APIクライアントの更新確認

CI/CDやpre-commitフックで、生成されたAPIクライアントが最新かどうかを確認できます：

```bash
# 生成されたAPIクライアントが最新かチェック
mise run check-api
```

このコマンドは、現在のAPIクライアントが最新のOpenAPIスキーマと一致しているかを確認します。不一致がある場合は、`mise run generate-api`を実行して更新してください。

## Dockerを使用した起動（バックエンド）

Dockerを使用する場合：

```bash
cd backend
# Docker Composeを使用
docker-compose up --build

# または、Dockerfileから直接ビルド
docker build -t snampo-backend .
docker run -p 80:80 --env-file .env snampo-backend
```
