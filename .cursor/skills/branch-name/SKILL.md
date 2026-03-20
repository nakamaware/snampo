---
name: branch-name
description: Use when creating new branches, extracting issue numbers from branch names, or validating branch name format
---

# ブランチ名

## 命名規則

```plaintext
<type>/<issue-num>-<description>
```

例: `feat/123-add-user-authentication`, `fix/45-resolve-login-bug`

- `<type>`: feat, fix, chore, docs, style, refactor, test, perf, ci, build, revert
- `<issue-num>`: issue番号（数字のみ）
- `<description>`: ハイフン区切り、小文字推奨
