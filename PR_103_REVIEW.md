# PR #103 レビュー: Terraformの設定

## 概要

このPRはsnampoプロジェクトのGCPリソースをTerraformで構成管理するためのセットアップです。開発環境(dev)と本番環境(prod)のインフラをコードで管理できるようにする重要な変更です。

---

## 全体評価

### ✅ 良い点

1. **明確なモジュール構成**: `env/` でルートモジュールを環境ごとに分け、`modules/` で再利用可能なモジュールを整理している
2. **適切な抽象化**: `modules/common` で共通設定を一元管理し、DRY原則に従っている
3. **GCPベストプラクティス**: Workload IdentityやSecret Managerなど、推奨される方法を採用
4. **詳細なREADME**: 構成の意図や開発方針が明確に文書化されている
5. **適切な依存関係管理**: `depends_on` を使用してリソースの作成順序を制御

---

## 詳細レビュー

### 1. ルートモジュール (`env/`) の構成

#### ✅ 良い点
- **環境分離が明確**: dev と prod で分離され、環境ごとの設定変更が容易
- **変数の使い方が適切**: `locals` で project_name と project_id を定義し、再利用
- **バックエンド設定**: GCS バックエンドでステート管理を適切に設定

#### ⚠️ 改善提案

**1.1 本番環境の未実装**
```hcl
# terraform/env/prod/main.tf は空ファイル
```
- **問題**: prod 環境の設定が空で、実装が完了していない
- **推奨**: dev と同様の構造を持たせるか、TODO コメントを追加

**1.2 バックエンド設定の循環依存リスク**
```hcl
# terraform/env/dev/backend.tf
terraform {
  backend "gcs" {
    bucket = "snampo-dev-bucket"  # このバケット自体をTerraformで管理している
    prefix = "terraform/state"
  }
}
```
- **問題**: ステート保存先のバケットを同じTerraformで管理している（ブートストラップ問題）
- **推奨**: 
  - バケットは手動で事前作成するか
  - 別のTerraformプロジェクトで管理
  - README に初回セットアップ手順を追記

**1.3 ハードコーディングされた値**
```hcl
# terraform/env/dev/main.tf
locals {
  project_id = "snampo-480404"  # ハードコーディング
}

sa_iam_config = [
  {
    email = "${local.project_name}-run@snampo-480404.iam.gserviceaccount.com"
    # ...
  }
]
```
- **問題**: project_id が複数箇所にハードコーディングされている
- **推奨**: `local.project_id` を一貫して使用

### 2. サブモジュール (`modules/gcp/`) のフォルダ構成

#### ✅ 良い点
- **責務の分離**: 各モジュールが単一の責務を持つ（api-key, cloud-run, iam-member など）
- **再利用可能**: どの環境でも使える汎用的な設計
- **変数の型定義**: 明確な型定義で入力の検証が可能

#### ⚠️ 改善提案

**2.1 outputs の不足**
```hcl
# 多くのモジュールに outputs.tf がない
# 例: service-account, iam-member, cloud-run
```
- **問題**: モジュールの出力値が取得できず、他のリソースから参照できない
- **推奨**: 必要な値（SA メールアドレス、Cloud Run URL など）を output として公開

**2.2 api-key モジュールのセキュリティ考慮**
```hcl
# terraform/modules/gcp/api-key/outputs.tf
output "key_strings" {
  value = {
    for key in var.api_keys :
    key.id => google_apikeys_key.basic_key["${key.id}"].key_string
  }
}
```
- **問題**: sensitive な API キーが output に含まれるが、`sensitive = true` が未設定
- **推奨**: `sensitive = true` を追加してログへの出力を防ぐ

**2.3 workload-identity モジュールのデータソース使用**
```hcl
# terraform/modules/gcp/workload-identity/main.tf
data "google_service_account" "service_account" {
  for_each   = toset([for b in var.sa_gh_repo_bindings : b.sa_id])
  project    = var.project_id
  account_id = each.value
}
```
- **問題**: SA が存在することを前提としており、エラーハンドリングが不明確
- **懸念**: `depends_on` が親モジュールに設定されているが、暗黙的な依存関係に頼っている
- **推奨**: より明示的な依存関係管理、またはSAメールアドレスを直接渡す方式も検討

### 3. 共通モジュール (`modules/common`) の構成

#### ✅ 良い点
- **一元管理**: プロジェクトで共通するリソースを1箇所で管理
- **公式モジュール活用**: Google 公式の Terraform モジュールを適切に使用
- **明確な依存関係**: depends_on で順序を制御

#### ⚠️ 改善提案

**3.1 必須変数の多さ**
```hcl
# terraform/modules/common/variables.tf
# 5つの必須変数がある
variable "gcs_bucket_names" { type = list(string) }
variable "gar_repository_id" { type = string }
variable "cloud_run_service_config" { ... }
```
- **問題**: common モジュールなのに必須変数が多く、柔軟性が低い
- **推奨**: デフォルト値を設定するか、オプション化を検討

**3.2 Cloud Run Service の固定実装**
```hcl
# terraform/modules/common/main.tf
module "cloud_run_service" {
  source = "../gcp/cloud-run"
  # ...
}
```
- **問題**: 1つの Cloud Run サービスしか作成できない
- **推奨**: リスト形式にして複数サービスに対応、または optional にする

**3.3 API 有効化のハードコーディング**
```hcl
# terraform/modules/common/main.tf
activate_apis = [
  "cloudresourcemanager.googleapis.com",
  "storage.googleapis.com",
  # ... 多数のAPI
  "directions-backend.googleapis.com", # TODO: Legacyになったので、Routes APIに置き換える。
]
```
- **良い点**: TODO コメントで Legacy API を認識している
- **推奨**: API リストを変数化して環境ごとに調整可能にする

**3.4 ロケーション設定の不一致**
```hcl
# terraform/env/dev/main.tf
provider "google" {
  region = "asia-northeast1"  # provider レベルで設定
}

# terraform/modules/common/variables.tf
variable "location" {
  default = "asia-northeast1"  # 変数でも設定
}
```
- **問題**: region/location の設定が重複している
- **推奨**: 1箇所で管理し、変数として渡す

### 4. セキュリティとベストプラクティス

#### ✅ 良い点
- **Workload Identity 使用**: キーファイル不要で安全
- **Secret Manager 統合**: 機密情報を適切に管理
- **最小権限の原則**: SA ごとに必要な権限のみ付与

#### ⚠️ 改善提案

**4.1 Owner 権限の使用**
```hcl
# terraform/env/dev/main.tf
sa_iam_config = [
  {
    email = "${local.project_name}-terraform@snampo-480404.iam.gserviceaccount.com"
    roles = ["roles/owner"]  # ⚠️ 強すぎる権限
  }
]
```
- **問題**: Terraform SA に Owner 権限を付与するのは過剰
- **リスク**: SA が侵害された場合の影響が甚大
- **推奨**: 必要な個別権限のみ付与（例: Editor + Storage Admin）

**4.2 .gitignore の設定が不十分**
```gitignore
# .gitignore
*.terraform
```
- **問題**: `.terraform.lock.hcl` は PR に含まれているが、他の Terraform ファイルが不足
- **推奨**: 以下を追加
```gitignore
*.terraform
.terraform.lock.hcl  # または明示的に除外しない（チーム方針による）
*.tfstate
*.tfstate.*
*.tfvars  # 機密情報が含まれる可能性
terraform.tfstate.d/
```

**4.3 deletion_protection の設定**
```hcl
# terraform/modules/gcp/cloud-run/main.tf
resource "google_cloud_run_v2_service" "default" {
  deletion_protection = false  # ⚠️ 本番環境では危険
}
```
- **問題**: 本番環境で誤削除のリスク
- **推奨**: 環境変数化し、本番では `true` に設定

**4.4 シークレットの取り扱い**
```hcl
# terraform/modules/common/variables.tf
variable "secrets" {
  type = list(object({
    name        = string
    secret_data = string  # ⚠️ sensitive でない
  }))
}
```
- **問題**: シークレットデータに `sensitive` マークがない
- **推奨**: 
```hcl
variable "secrets" {
  type = list(object({
    name        = string
    secret_data = string
  }))
  sensitive = true  # 追加
}
```

### 5. コードの品質と保守性

#### ✅ 良い点
- **コメント**: 日本語コメントで意図が明確
- **命名規則**: 一貫した命名でわかりやすい
- **モジュール化**: 適切な粒度でモジュール分割

#### ⚠️ 改善提案

**5.1 動的ブロックの可読性**
```hcl
# terraform/modules/gcp/cloud-run/main.tf
dynamic "env" {
  for_each = { for e in var.container_specs.env : e.name => e.value }
  content {
    name  = env.key
    value = env.value
  }
}
```
- **良い点**: 動的に環境変数を設定できる
- **推奨**: リスト形式なので、`for_each` よりも `for` を使った方がシンプルかも

**5.2 TODO コメントの追跡**
```hcl
# terraform/env/dev/main.tf
# TODO: これ消して、実際に利用するAPIキーを作成する
```
- **問題**: TODO が残っており、テスト用の設定が本番に影響する可能性
- **推奨**: GitHub Issue でトラッキング、または削除のタイミングを明確化

**5.3 変数のバリデーション不足**
```hcl
# terraform/modules/common/variables.tf
variable "project_id" {
  type = string
  # validation が未定義
}
```
- **推奨**: 重要な変数にバリデーションを追加
```hcl
variable "project_id" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must follow GCP naming conventions."
  }
}
```

### 6. ドキュメント

#### ✅ 良い点
- **README.md**: 構成と開発方針が明確
- **シークレット管理**: 取り扱い方法が文書化されている

#### ⚠️ 改善提案

**6.1 初回セットアップ手順の不足**
- **問題**: Terraform を初めて実行する手順が不明
- **推奨**: README に以下を追加
  - 前提条件（GCP プロジェクト作成、認証設定）
  - terraform init の実行方法
  - ステートバケットの事前作成方法

**6.2 モジュールごとのドキュメント不足**
- **問題**: 各モジュールに README がない
- **推奨**: terraform-docs などで自動生成を検討

---

## 優先度別の修正推奨事項

### 🔴 高優先度（セキュリティ・重大なリスク）

1. **Owner 権限の見直し**: Terraform SA の権限を最小化
2. **API キーの sensitive 設定**: 機密情報の漏洩防止
3. **バックエンド設定の循環依存**: ブートストラップ問題の解決
4. **.gitignore の補完**: tfstate や tfvars の除外

### 🟡 中優先度（機能性・保守性）

5. **本番環境の実装**: prod 環境の設定を完成させる
6. **outputs の追加**: モジュール間の連携を改善
7. **変数のバリデーション**: 入力値の検証を強化
8. **deletion_protection の環境別設定**: 本番環境の保護

### 🟢 低優先度（改善・最適化）

9. **TODO の解消**: テスト用設定の削除
10. **API リストの変数化**: 柔軟性の向上
11. **モジュールのドキュメント追加**: 保守性の向上
12. **初回セットアップ手順の追加**: 開発者体験の向上

---

## モジュール構成の評価まとめ

### ルートモジュール（env/）: ⭐⭐⭐⭐☆ (4/5)
- **良い点**: 環境分離が明確、変数の使い方が適切
- **改善点**: 本番環境の未実装、ハードコーディングの削減

### サブモジュール（modules/gcp/）: ⭐⭐⭐⭐☆ (4/5)
- **良い点**: 責務の分離、再利用可能な設計
- **改善点**: outputs の不足、セキュリティ設定の強化

### 共通モジュール（modules/common）: ⭐⭐⭐☆☆ (3/5)
- **良い点**: 一元管理、公式モジュール活用
- **改善点**: 柔軟性の向上、必須変数の削減、Cloud Run の複数対応

---

## 総合評価: ⭐⭐⭐⭐☆ (4/5)

このPRは、Terraform の基本的な構成として**非常に良い出発点**です。モジュール構成は理解しやすく、GCP のベストプラクティスに従っています。

ただし、以下の点で改善の余地があります：
- セキュリティ設定の強化（特に権限管理）
- 柔軟性の向上（変数化、オプション化）
- 本番環境への対応完了
- ドキュメントの充実

上記の高優先度項目を対応すれば、プロダクション環境で安全に使用できる品質に達すると考えます。

---

## 次のステップ

1. **高優先度の問題を修正**（特にセキュリティ関連）
2. **本番環境の設定を完成**させる
3. **初回セットアップの手順を文書化**
4. **チームでレビュー**し、運用方針を確認
5. **段階的にデプロイ**: dev → prod の順で適用

---

## 質問・確認事項

1. `.terraform.lock.hcl` はリポジトリにコミットする方針ですか？
   - コミットする場合: プロバイダーバージョンを固定できる（推奨）
   - しない場合: .gitignore に追加

2. 本番環境の設定は dev と同じ構造にする予定ですか？
   - 同じ場合: 早めに雛形を作成
   - 異なる場合: どのような違いがあるか明確化

3. Terraform の実行環境はどこですか？
   - GitHub Actions: Workload Identity の設定が必要
   - ローカル: 認証方法の文書化が必要

4. ステートファイルのロックはどう管理しますか？
   - GCS のロック機能を使用（推奨）
   - または別のロック機構

---

## 参考リンク

- [Google Cloud Terraform Best Practices](https://cloud.google.com/docs/terraform/best-practices-for-terraform)
- [Terraform Security Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices/security)
- [GCP IAM Best Practices](https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation)
