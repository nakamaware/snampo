# リソースを作成するプロジェクトのID
variable "project_id" {
  type = string
}

# リソースを作成するリージョン
variable "location" {
  type    = string
  default = "asia-northeast1"
}

# 作成するAPIキー
variable "api_keys" {
  type = list(object({
    id              = string
    display_name    = string
    target_services = list(string)
  }))
  default = []
}

# Secret Managerに登録するSecret
variable "secrets" {
  type = list(object({
    name        = string
    secret_data = string
  }))
  default = []
}

# 作成するService Account
variable "sa_list" {
  type = list(object({
    id   = string
    desc = string
  }))
  default = []
}

# グループの権限
variable "grp_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
  default = []
}

# Service Accountの権限
variable "sa_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
  default = []
}

# Service AccountとGitHubリポジトリの連携
variable "sa_gh_repo_bindings" {
  type = list(object({
    sa_id = string
    repos = list(string)
  }))
  default = []
}

# Cloud Storageのバケット名
variable "gcs_bucket_names" {
  type = list(string)
}

# Artifact RegistryのID
variable "gar_repository_id" {
  type = string
}

# Cloud Runの設定
variable "cloud_run_service_config" {
  type = object({
    service_name    = string
    service_account = string
    container_specs = object({
      env = list(object({
        name  = string
        value = string
      }))
      env_secret = list(object({
        name      = string
        secret_id = string
      }))
      port = string
    })
  })
}
