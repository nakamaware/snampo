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

4. **miseでツールをインストール**

   ```bash
   # 初回のみ、設定ファイルを信頼する必要があります
   mise trust
   
   # ツールをインストール
   mise install
   ```

   これにより、プロジェクトに必要なFlutterとJavaのバージョンが自動的にインストールされます。

5. **依存関係のインストール**

   ```bash
   # プロジェクトルートから実行（フロントエンドとバックエンドの両方の依存関係をインストール）
   mise run setup
   ```

   または個別に実行する場合：

   ```bash
   # フロントエンドのみ
   mise run frontend:pub-get
   
   # バックエンドのみ
   mise run backend:sync
   ```

6. **pre-commitのセットアップ**

   pre-commitをインストールして、Gitフックを有効化します：

   ```bash
   # pre-commitをインストール（uvを使用する場合）
   uv pip install pre-commit
   
   # または、pipを使用する場合
   pip install pre-commit
   
   # Gitフックをインストール
   pre-commit install
   ```

   これにより、コミット前に自動的にコード品質チェックが実行されます。
   
   初回実行時や設定変更後は、全ファイルに対してチェックを実行することもできます：
   
   ```bash
   pre-commit run --all-files
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

   ```env
   GOOGLE_API_KEY=your_google_maps_api_key_here
   ```

詳細は `frontend/README.md` を参照してください。

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

#### フロントエンドタスク

```bash
# 開発サーバーを起動
mise run frontend:dev

# 依存関係をインストール
mise run frontend:pub-get

# Debug APKをビルド
mise run frontend:build

# Release APKをビルド
mise run frontend:build-release

# テストを実行
mise run frontend:test

# ビルドキャッシュをクリア
mise run frontend:clean

# コードをフォーマット
mise run frontend:format

# コードを解析
mise run frontend:analyze
```

#### バックエンドタスク

```bash
# 開発サーバーを起動
mise run backend:dev

# 依存関係をインストール
mise run backend:sync

# テストを実行
mise run backend:test

# コードをフォーマット
mise run backend:format

# コードをリント
mise run backend:lint
```

#### 統合タスク

```bash
# フロントエンドとバックエンドを同時に起動
mise run dev

# プロジェクトの初期セットアップ（依存関係のインストール）
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

---

## 開発

### 開発サーバーの起動

#### フロントエンドとバックエンドを同時に起動

```bash
# プロジェクトルートから実行
mise run dev
```

#### 個別に起動する場合

```bash
# フロントエンドのみ
mise run frontend:dev

# バックエンドのみ
mise run backend:dev
```

### ホットリロード

#### Frontend

アプリ実行中に `r` キーを押すとホットリロードが実行されます。

#### Backend

Uvicornの`--reload`オプションにより、コード変更時に自動的に再起動されます。

## トラブルシューティング

### Frontend（トラブルシューティング）

#### miseがツールを認識しない場合

```bash
# miseのシェル統合を確認
mise activate

# シェルを再起動するか、以下を実行
eval "$(mise activate zsh)"  # zshの場合
eval "$(mise activate bash)" # bashの場合
```

#### Flutterのパスが正しく設定されない場合

```bash
# Flutterのパスを確認
which flutter

# miseでFlutterを再インストール
mise uninstall flutter
mise install
```

### Backend（トラブルシューティング）

#### uvが見つからない場合

```bash
# uvのパスを確認
which uv

# シェルを再起動するか、PATHを確認
echo $PATH
```

#### 依存関係のインストールに失敗する場合

```bash
# 仮想環境を削除して再作成
rm -rf .venv
uv sync
```

#### Python 3.13が見つからない場合

```bash
# Pythonのバージョンを確認
python --version

# uvを使用してPythonをインストール
uv python install 3.13
```
