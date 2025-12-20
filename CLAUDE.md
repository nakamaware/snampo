# Claude用プロジェクトガイド

## ブランチ命名規則

```
<prefix>/<issue-num>-<name>
```

**プレフィックス:**
- `chore/` - CI/CD、設定変更
- `docs/` - ドキュメント
- `feature/` - 新機能
- `fix/` - バグ修正
- `refactor/` - リファクタリング

**例:** `chore/49-remove-development-from-ci`

## コミットメッセージ規則

Conventional Commits v1.0.0 の形式で日本語で記述する。

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**タイプ:**
- `chore` - CI/CD、設定変更、ビルドプロセス、補助ツールの変更
- `docs` - ドキュメントのみの変更
- `feat` - 新機能
- `fix` - バグ修正
- `refactor` - リファクタリング（機能追加もバグ修正も含まないコード変更）
- `style` - コードの動作に影響しない変更（フォーマット、セミコロン欠落など）
- `test` - テストの追加・変更
- `perf` - パフォーマンス改善
- `ci` - CI設定やスクリプトの変更
- `build` - ビルドシステムや依存関係の変更

**例:**
- `chore: CIワークフローからdevelopmentブランチを削除`
- `feat: ユーザー認証機能を追加`
- `fix: ログイン時のエラーハンドリングを修正`
