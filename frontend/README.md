# snampo

A new Flutter project.

## セットアップ

セットアップ手順については、プロジェクトルートの [`README.md`](../README.md) を参照してください。

## アーキテクチャ

このプロジェクトは **レイヤードアーキテクチャ（Layered Architecture）** を採用しており、Clean Architectureの一部の原則（依存性逆転の原則）を取り入れています。

### レイヤー構造

プロジェクトは以下の3つのレイヤーに分かれています：

```
lib/
├── domain/          # ドメイン層（ビジネスオブジェクトとインターフェース）
│   ├── entities/    # エンティティ（ビジネスオブジェクト）
│   └── repositories/ # リポジトリのインターフェース
├── data/            # データ層（データソースと実装）
│   ├── datasources/ # APIクライアントなどのデータソース
│   ├── models/      # DTO（Data Transfer Object）
│   └── repositories/ # リポジトリの実装
└── presentation/    # プレゼンテーション層（UI）
    ├── controllers/ # 状態管理（Riverpod）
    └── pages/       # UIページ
```

### 依存性の方向

依存性は以下の方向に流れます：

```
presentation → domain ← data
```

- **domain層**: 最も独立した層。他の層に依存しないエンティティとインターフェースを定義
- **data層**: domain層のインターフェースを実装し、外部APIやデータソースと通信
- **presentation層**: domain層のエンティティとリポジトリを使用してUIを構築

### Clean Architectureとの違い

このプロジェクトは完全なClean Architectureではなく、レイヤードアーキテクチャです。主な違いは以下の通りです：

- **ユースケース層がない**: Clean Architectureでは、ビジネスロジックを実行するユースケース層がありますが、このプロジェクトではコントローラーが直接リポジトリを呼び出しています
- **シンプルな構造**: 小規模なアプリケーションに適したシンプルな3層構造を採用

ただし、以下のClean Architectureの原則は取り入れています：

- **依存性逆転の原則**: リポジトリのインターフェースをdomain層に定義し、data層で実装することで、domain層の独立性を保っています

### 主な技術スタック

#### 状態管理
- **[Riverpod](https://riverpod.dev/)**: 状態管理ライブラリ。`riverpod_annotation`と`riverpod_generator`を使用してコード生成による型安全なプロバイダー定義を実現
  - **選定理由**: Providerの後継として設計され、コンパイル時型安全性、テスト容易性、パフォーマンスに優れる。コード生成により、実行時エラーを防ぎ、IDEの補完も充実している
- **[flutter_hooks](https://pub.dev/packages/flutter_hooks)**: Flutter Hooks。関数コンポーネント風の書き方で状態管理やライフサイクルを扱う
  - **選定理由**: React Hooksに似たAPIで、状態管理とライフサイクルを簡潔に記述できる。再利用可能なロジックの分離が容易
- **[hooks_riverpod](https://pub.dev/packages/hooks_riverpod)**: RiverpodとFlutter Hooksの統合
  - **選定理由**: RiverpodとFlutter Hooksを組み合わせることで、関数コンポーネント風の書き方でRiverpodのプロバイダーを利用可能

#### ルーティング
- **[GoRouter](https://pub.dev/packages/go_router)**: 宣言的なルーティングライブラリ。URLベースのナビゲーションとディープリンクをサポート
  - **選定理由**: Navigator 2.0を簡潔に扱える。URLベースのルーティング、ディープリンク、ブラウザの戻る/進むボタン対応など、Webアプリケーションにも適している

#### データモデル・シリアライゼーション
- **[Freezed](https://pub.dev/packages/freezed)**: イミュータブルなクラスとユニオン型の生成。`freezed_annotation`と`freezed`を使用
  - **選定理由**: イミュータブルなデータクラスを自動生成し、`copyWith`、`toString`、`==`、`hashCode`などを自動実装。パターンマッチングによるユニオン型もサポートし、型安全性が高い
- **[json_serializable](https://pub.dev/packages/json_serializable)**: JSONシリアライゼーションコードの自動生成。`json_annotation`と`json_serializable`を使用
  - **選定理由**: 手動でのシリアライゼーション実装を避け、ボイラープレートコードを削減。型安全なJSON変換を実現

#### HTTP通信
- **[Dio](https://pub.dev/packages/dio)**: 強力なHTTPクライアント。インターセプター、リトライ、キャンセルなどの機能を提供
  - **選定理由**: 標準の`http`パッケージより高機能。インターセプターによるリクエスト/レスポンスの加工、自動リトライ、リクエストキャンセルなど、実用的な機能が豊富
- **[http](https://pub.dev/packages/http)**: Dart標準のHTTPクライアント（補助的に使用）
  - **選定理由**: 軽量で標準的なHTTPクライアント。シンプルな用途や補助的な用途で使用

#### 地図・位置情報
- **[google_maps_flutter](https://pub.dev/packages/google_maps_flutter)**: Google MapsをFlutterアプリに統合
  - **選定理由**: Google公式のパッケージで、Google Mapsの豊富な機能を利用可能。地図表示、マーカー、カスタムスタイルなどに対応
- **[geolocator](https://pub.dev/packages/geolocator)**: 位置情報の取得と位置情報サービスへのアクセス
  - **選定理由**: 位置情報取得のデファクトスタンダード。iOS/Android両方で安定して動作し、パーミッション管理も簡潔
- **[flutter_polyline_points](https://pub.dev/packages/flutter_polyline_points)**: ポリライン（経路）のポイントを生成
  - **選定理由**: Google Directions APIのポリライン文字列をデコードして座標リストに変換。経路表示に必要
- **[flutter_polyline](https://pub.dev/packages/flutter_polyline)**: ポリラインを地図上に表示
  - **選定理由**: ポリラインを地図上に描画するためのシンプルなパッケージ。経路の可視化に使用

#### UI・デザイン
- **[google_fonts](https://pub.dev/packages/google_fonts)**: Google Fontsを簡単に使用可能にするライブラリ
  - **選定理由**: Google Fontsの豊富なフォントを簡単に使用可能。アセットバンドルに含めずに動的に読み込める
- **[loading_animation_widget](https://pub.dev/packages/loading_animation_widget)**: ローディングアニメーションウィジェット
  - **選定理由**: 多様なローディングアニメーションを提供。カスタマイズも容易で、UX向上に貢献
- **[image_picker](https://pub.dev/packages/image_picker)**: デバイスのカメラやギャラリーから画像を選択
  - **選定理由**: Flutter公式が推奨する画像選択パッケージ。iOS/Android両方で安定して動作し、カメラとギャラリーの両方に対応

#### 開発ツール
- **[build_runner](https://pub.dev/packages/build_runner)**: コード生成を実行するためのビルドツール
  - **選定理由**: Freezed、json_serializable、riverpod_generatorなどのコード生成ツールを実行するための標準ツール
- **[very_good_analysis](https://pub.dev/packages/very_good_analysis)**: Very Good Venturesが提供するDart/Flutter用のリンター設定
  - **選定理由**: Flutter開発のベストプラクティスに基づいた包括的なリンター設定。コード品質の維持に役立つ

### 設計原則

1. **依存性逆転の原則**: リポジトリのインターフェースはdomain層に定義し、data層で実装
2. **単一責任の原則**: 各クラスは単一の責任を持つ
3. **関心の分離**: ビジネスロジック、データアクセス、UIを明確に分離
4. **テスタビリティ**: 各層を独立してテスト可能

## コード品質ツール

このプロジェクトでは、コードの品質を保つために以下のツールを使用しています。

### リンター・静的解析

プロジェクトでは [very_good_analysis](https://pub.dev/packages/very_good_analysis) を使用してコードの静的解析を行っています。

リンターの設定は `analysis_options.yaml` で管理されています：

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  errors:
    invalid_annotation_target: ignore
```

`invalid_annotation_target` エラーは無視するように設定されています（freezedなどのコード生成ツールとの互換性のため）。

### コード生成

このプロジェクトでは、以下のコード生成ツールを使用しています：

- **freezed**: イミュータブルなクラスとユニオン型の生成
- **json_serializable**: JSONシリアライゼーションコードの生成
