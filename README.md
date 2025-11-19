# Snampo

Snampoプロジェクトのリポジトリです。

## プロジェクト構成

- `frontend/`: Flutterアプリケーション
- `backend/`: FastAPIバックエンド

## 環境構築

### Frontend環境構築

FrontendはFlutterで開発されています。

#### 必要なツール

- [mise](https://mise.jdx.dev/) - バージョン管理ツール
- Android Studio（Android開発用）

#### セットアップ手順

1. **miseのインストール**（未インストールの場合）

   ```bash
   # macOS / Linux
   curl https://mise.run | sh
   
   # または Homebrew
   brew install mise

   # Windows
   winget install jdx.mise
   ```

   参考: https://mise.jdx.dev/getting-started.html

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

   Google Maps API キーを設定するために、`secret.properties.example` をコピーして `secret.properties` を作成し、API キーを設定してください。

   ```bash
   cd android
   cp secret.properties.example secret.properties
   ```

   その後、`android/secret.properties` を開いて `YOUR_GOOGLE_MAPS_API_KEY_HERE` を実際の Google Maps API キーに置き換えてください。

7. **アプリの実行**

   ```bash
   flutter run
   ```

詳細は `frontend/README.md` を参照してください。

#### 使用しているツールバージョン

- **Flutter**: 3.32.0
- **Java**: 17
- **Gradle**: 8.10.2
- **Kotlin**: 2.0.21
- **Android Gradle Plugin**: 8.8.0
- **Android SDK**: 36 (compileSdkVersion, targetSdkVersion)

---

### Backend環境構築

BackendはFastAPIで開発されており、[uv](https://github.com/astral-sh/uv)を使用して依存関係を管理します。

#### 必要なツール

- **Python**: 3.13
- **[uv](https://github.com/astral-sh/uv)**: Pythonパッケージマネージャー

#### uvのインストール

```bash
# macOS / Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# または Homebrew
brew install uv

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

参考: https://github.com/astral-sh/uv#installation

#### セットアップ手順

1. **プロジェクトディレクトリに移動**

   ```bash
   cd backend
   ```

2. **仮想環境の作成と依存関係のインストール**

   ```bash
   # 仮想環境を作成し、依存関係をインストール
   uv sync
   ```

   これにより、`.venv`ディレクトリに仮想環境が作成され、`pyproject.toml`に記載された依存関係がインストールされます。

   **注意**: `uv run`を使用すれば、仮想環境の有効化は不要です。`uv run`コマンドは自動的に仮想環境下でコマンドを実行します。

3. **環境変数の設定**

   Google Maps API キーを設定するために、`.env.example`をコピーして`.env`ファイルを作成してください。

   ```bash
   # .env.exampleをコピーして.envを作成
   cp .env.example .env
   ```

   その後、`.env`ファイルを開いて、`your_google_maps_api_key_here`を実際のGoogle Maps APIキーに置き換えてください。

   ```
   GOOGLE_API_KEY=your_google_maps_api_key_here
   ```

4. **開発サーバーの起動**

   ```bash
   # uv runを使用して実行（推奨）
   uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

   サーバーは `http://localhost:8000` で起動します。

   **その他のコマンド例**:
   ```bash
   # Pythonスクリプトの実行
   uv run python script.py

   # パッケージのインストール
   uv add package-name

   # 開発依存関係の追加
   uv add --dev package-name
   ```

#### Dockerを使用した起動

Dockerを使用する場合：

```bash
# Docker Composeを使用
docker-compose up --build

# または、Dockerfileから直接ビルド
docker build -t snampo-backend .
docker run -p 80:80 --env-file .env snampo-backend
```

#### 依存関係の管理

- **依存関係の追加**: `pyproject.toml`の`dependencies`セクションに追加後、`uv sync`を実行
- **依存関係の更新**: `uv sync --upgrade`
- **依存関係のロック**: `uv lock`（`uv.lock`ファイルが生成されます）

#### 使用しているツールバージョン

- **Python**: 3.13
- **FastAPI**: >=0.104.0
- **Uvicorn**: >=0.24.0
- **Requests**: >=2.31.0
- **Folium**: >=0.15.0

---

## 開発

### ホットリロード（Frontend）

アプリ実行中に `r` キーを押すとホットリロードが実行されます。

### ホットリロード（Backend）

Uvicornの`--reload`オプションにより、コード変更時に自動的に再起動されます。

## トラブルシューティング

### Frontend

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

### Backend

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

