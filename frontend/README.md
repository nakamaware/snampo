# snampo

A new Flutter project.

## セットアップ

セットアップ手順については、プロジェクトルートの [`README.md`](../README.md) を参照してください。

## アーキテクチャ

このプロジェクトは **シンプルなレイヤードアーキテクチャ** を採用しています。小規模なアプリケーションに適した、過剰に複雑でない構造を心がけています。

### ディレクトリ構造

プロジェクトは以下の構造で整理されています：

```
lib/
├── app.dart         # アプリケーションのルート設定
├── main.dart        # エントリーポイント
├── config.dart      # 環境設定（API URLなど）
├── models/          # データモデル（エンティティ）
│   └── location_entity.dart
├── repositories/   # データアクセス層（API通信など）
│   └── mission_repository.dart
└── presentation/    # プレゼンテーション層（UI）
    ├── controllers/ # 状態管理（Riverpod）
    └── pages/       # UIページ
```

### 設計方針

- **シンプルさを優先**: 過剰な抽象化を避け、必要最小限の構造を維持
- **関心の分離**: データモデル、データアクセス、UIを明確に分離
- **実用性重視**: 小規模なアプリケーションに適した実用的な構造

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

#### HTTP通信・APIクライアント
- **[snampo_api](packages/snampo_api/)**: OpenAPIスキーマから自動生成されたAPIクライアントパッケージ
  - **選定理由**: バックエンドのOpenAPIスキーマから自動生成されるため、型安全性が高く、APIの変更に自動的に対応できる。手動でのAPIクライアント実装を不要にし、ボイラープレートコードを削減
  - **生成方法**: `mise run generate-api` コマンドで生成（詳細はプロジェクトルートのREADMEを参照）
- **[Dio](https://pub.dev/packages/dio)**: 強力なHTTPクライアント（現在は生成されたAPIクライアントの内部で使用）
  - **選定理由**: 標準の`http`パッケージより高機能。インターセプターによるリクエスト/レスポンスの加工、自動リトライ、リクエストキャンセルなど、実用的な機能が豊富
- **[http](https://pub.dev/packages/http)**: Dart標準のHTTPクライアント（生成されたAPIクライアントの内部で使用）
  - **選定理由**: 軽量で標準的なHTTPクライアント。生成されたAPIクライアントが内部で使用

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

1. **単一責任の原則**: 各クラスは単一の責任を持つ
2. **関心の分離**: データモデル、データアクセス、UIを明確に分離
3. **シンプルさ**: 過剰な抽象化を避け、必要最小限の構造を維持
4. **実用性**: 小規模なアプリケーションに適した実用的な設計

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
  - エンティティクラスの生成に使用（現在は使用していないが、将来の拡張に備えて設定済み）
- **json_serializable**: JSONシリアライゼーションコードの生成
  - エンティティクラスのJSON変換に使用（現在は使用していないが、将来の拡張に備えて設定済み）
- **riverpod_generator**: Riverpodプロバイダーのコード生成
  - 型安全なプロバイダー定義を実現
- **OpenAPI Generator**: バックエンドのOpenAPIスキーマからDart APIクライアントを生成
  - `mise run generate-api` コマンドで実行
  - 生成されたAPIクライアント（`snampo_api`）を直接使用することで、型安全なAPI通信を実現
