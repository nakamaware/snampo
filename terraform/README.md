## ファイル構成

### ルートモジュール

開発環境と本番環境でルートモジュールを分けて構成を管理。

* env/dev: 開発環境

* env/prod: 本番環境

### サブモジュール

* common

  * snampoの共通設定が入るモジュール。

* gcp

  * GCPのリソースを構成するサブモジュールが入る。

## 開発の方針

### ルートモジュール

ルートモジュールでは開発・本番プロジェクトで共通の構成となるリソースの最低限の設定と、各環境で必要なリソースを定義する。

### サブモジュール

開発環境と本番環境で共通するリソースを追加・削除する場合は`common`に変更を加える。各環境に対して個別でリソースを追加・削除する場合は`env/*`に対して変更を加える。複数のリソースの定義が必要になる場合は`gcp`などのサブモジュールを定義して呼び出すようにする。サブモジュールの作成・追加は、公開されているモジュールで代用できない場合に限定する。サブモジュールを作成する際は、推奨設定をハードコーディングし、プロジェクトによって変更が必要な設定を変数で設定できるようにする。

### シークレットの扱い

基本的に、GCPで生成するシークレット（APIキーなど）とGCP以外のシークレット（GitHub AppsのSecretなど）の2つがある。GCPのシークレットはTerraformでシークレットを作成してSecret Managerに登録することでGCP上のリソースで利用できる。GCP以外のシークレットは`TF_VAR_{xxx}`の環境変数をGitHubリポジトリのSecretに設定して、GitHub Actionsで`terrafrom apply`する際に変数としてTerraformに注入する。

## 初期セットアップ

### 権限の確認とGCPの認証

GCPでOwner権限があれば、ほとんどのリソースの作成・削除は問題なく行える。Editor権限だとIAMリソースの変更は不可、それ以外は大体変更できる。

```bash
gcloud auth application-default login
```

### 手順

Terraform CLIをインストール

* https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

ルートモジュール（env/devまたはenv/prod）で状態を初期化

```bash
terraform init
```

インフラの変更の確認

```bash
terraform plan
```

変更の適用（原則**ローカルではやらない**）

```bash
terraform apply
```

## 新しく環境を追加する場合（ステージング環境など）

**Owner権限が必要**

env以下にルートモジュールを追加する。

```text
env
└── stg
    ├── backend.tf  # 空ファイル
    └── main.tf     # プロバイダ+共通モジュールの呼び出しなど
```

backend.tfが空の状態で状態を初期化する。この時点でenv/stgに状態管理用のファイルが作成される。

```bash
# env/stgで実行
terraform init
```

Terraform用のリソースを作成する。（別の管理用プロジェクトでこれらを作成するでも良い。）

* Terraformのバックエンド

  * Google Cloud Storage

* TerraformのCI/CD用リソース
  
  * サービスアカウント（Owner権限）
  
  * Workload Identity連携（snampoリポジトリと上記サービスアカウントの連携）

例：env/stg/main.tf

```terraform
...(Providerの定義)

# commonモジュールの中にsnampoに必要なデフォルトの設定が入っている。
module "snampo_stg" {
  source = "../../modules/common"

  project_id = "snampo-stg"
  project_name = "snampo-stg"
}
```

上記の構成を適用する

```shell
# env/stgで実行
terraform apply
```

backend.tfにリモートバックエンドを追加する。

例：env/stg/backend.tf

```terraform
terraform {
  backend "gcs" {
    bucket = "snampo-stg-bucket"
    prefix = "terraform/state"
  }
}
```

ローカルからリモートバックエンドに状態管理を移行する。

```bash
# env/stgで実行
terraform init -migrate-state
```
