# フロントエンドアーキテクチャ (MVHR)

`frontend/` の設計方針とディレクトリ規約を共有する。コードレビュー時の観点もここにまとめる。

基本方針は、[Riverpod と Flutter Hooks で作る、宣言的 UI に適した Flutter アーキテクチャ](https://www.m3tech.blog/entry/2025/07/31/150000) で紹介されている **MVHR (Model-View-Hooks-Riverpod)** と同型である。クライアント設計を「状態管理」と「UI 制御」の組み合わせとして捉え、**状態の種類ごとに道具を分ける**。

## 状態の分け方

| 種類 | 役割 | このリポジトリでの主な担当 |
|------|------|---------------------------|
| **App State (global)** | 機能・画面をまたいで共有する状態 | **Riverpod** (`@riverpod` / `ConsumerWidget` / `HookConsumerWidget` 内の `ref.watch` など) |
| **Ephemeral state (local)** | ウィジェット木のスコープで完結する状態 | **flutter_hooks** (`useState` / `useMemoized` / カスタム `useXxx` など) |

MVVM のように画面と ViewModel が 1 対 1 になる前提ではなく、**小さな Widget に分割し、グローバルは Provider・ローカルは Hooks** で持つ。グローバルな「単一の正」 (single source of truth) を崩さないこと (同じドメインについて Riverpod と Hooks の両方に「正」とすべき状態を重ねすぎない、など) に注意する。

## レイヤーとディレクトリ

### 機能フォルダ (`lib/features/<feature>/`)

- `<feature>` は **英語の snake_case** (例: `mission`, `history`, `home`)。
- 各機能の直下に置くサブディレクトリは、次の **5 つのみ** とする (必要がなければ作らない)。**この表にないパスを新設しない。**

```text
lib/features/<feature>/
├── application/
│   ├── interface/          # 抽象: <name>_repository.dart, <name>_service.dart など
│   └── usecase/            # <name>_use_case.dart (1 ファイル 1 ユースケース)
├── data/
│   ├── repository/         # 具象リポジトリ: <name>_repository.dart
│   ├── mapper/             # 任意: <name>_mapper.dart (API / DB と domain の変換)
│   └── database/           # 任意: Drift 等の定義
├── di/                       # 当機能の Provider 定義・配線 (*.dart)
├── domain/
│   ├── entity/               # エンティティ (*.dart)
│   └── value_object/         # 値オブジェクト (*.dart)
└── presentation/
    ├── hook/                 # カスタムフック: use_<name>.dart
    ├── page/                 # 画面: <name>_page.dart
    ├── store/                # Riverpod の Notifier / 生成 Provider 本体 (*.dart, *.g.dart 等)
    └── util/                 # 任意: UI 都合のヘルパ (ドメインルールは置かない)
```

**data レイヤーの追加ルール**

- **リポジトリの具象実装**は **`data/repository/`** にだけ置く (`data/` 直下の `*_repository.dart` は新規で増やさない。触ったタイミングで `repository/` へ移す)。
- **`repository/` / `mapper/` / `database/` に収めない**データ境界 (位置情報、ファイル I/O、外部 SDK など) は **`data/` 直下** に **`*_service.dart`** または **`*_storage.dart`** として置く (1 ファイル 1 責務。**`*_repository.dart` は直下に置かない**)。
- **mapper / database** を使う場合のみそれぞれのディレクトリを作る。空ディレクトリをコミットしない。
- **application/interface/** にある抽象に対応する実装を **data 以外** に置かない。

**domain レイヤー**

- **entity** と **value_object** 以外の `domain/` 直下ファイルは置かない (サブディレクトリを増やさない)。

**presentation レイヤー**

- 含めてよいのは **`hook/`**, **`page/`**, **`store/`**, **`util/`** のみ。**`widget/` など別サブディレクトリは作らない。**
- **画面およびその画面専用の Widget** はすべて **`page/`** に置く (複数ファイルに分けてよい。命名は `<機能>_<役割>_page.dart` や `*_page.dart` など、既存の `snake_case` に合わせる)。

### 機能外 (`lib/`)

- **機能を横断するインフラ** (ルーティング、HTTP クライアント、汎用ストレージなど) は **`lib/core/`** に置く。
- **`main.dart`**, **`config.dart`** のみルートに置いてよい。ビジネスロジックや画面を `features/` 外に増やさない。

記事の Data / Logic (Use Case) / UI に相当する分離として、上記の **data / domain / application / presentation** を挟み、**di** で Riverpod の配線をまとめる。

ユースケースは **flutter / Riverpod に依存しない** 形に寄せ、ストアから `ref.read(someUseCaseProvider)` のように呼ぶとテストと責務分離がしやすい (MVHR 記事の Logic layer と同じ理由)。
