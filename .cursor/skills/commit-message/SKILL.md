---
name: commit-message
description: Use when writing commit messages or formatting commits according to project conventions
---

# コミットメッセージ

## 形式

Conventional Commit v1.0.0形式で日本語で書く。

```
<type>: <description>

<body>

Refs: #<issue-num>
```

例:
```
feat: ユーザー認証機能を追加

- ログイン機能を実装
- セッション管理を追加

Refs: #123
```

## issue番号の取得

ブランチ名からissue番号を取得して、コミットメッセージ末尾のフッター行に `Refs: #<issue-num>` を追加。

```bash
# ブランチ名からissue番号を抽出
git branch --show-current | sed -E 's/.*\/([0-9]+)-.*/\1/'
```
