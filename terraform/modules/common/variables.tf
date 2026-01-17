# リソースを作成するプロジェクトのID
variable "project_id" {
  type = string
}

# プロジェクト名
variable "project_name" {
  type = string
}

# リソースを作成するリージョン
variable "location" {
  type    = string
  default = "asia-northeast1"
}

# 有効にするAPI
variable "api_list" {
  type    = list(string)
  default = []
}

# 作成するService Account
variable "service_account_list" {
  type = list(object({
    id   = string
    desc = string
  }))
  default = []
}

# グループの権限
variable "group_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
  default = []
}

# Service Accountの権限
variable "service_account_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
  default = []
}

# Service AccountとGitHubリポジトリの連携（nakamawareが管理するリポジトリ限定）
variable "sa_gh_repo_binding_list" {
  type = list(object({
    sa_id = string
    repos = list(string)
  }))
  default = []
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

# Artifact RegistryのID（Docker）
variable "gar_repository_list" {
  type = list(object({
    id                    = string
    desc                  = string
    package_name_prefixes = list(string)
  }))
  default = []
}

# Cloud Runの設定
variable "cloud_run_service_configs" {
  type = list(object({
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
      port = number
    })
  }))

  default = []
}
