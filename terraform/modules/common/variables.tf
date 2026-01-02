# リソースを作成するプロジェクトのID
variable "project_id" {
  type = string
}

# リソースを作成するリージョン
variable "location" {
  type    = string
  default = "asia-northeast1"
}

# Secret Managerに登録するSecret
variable "secrets" {
  type = list(object({
    name = string
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

# Cloud Runの設定
# variable "cloud_run_service_name" {
#   type = object({
#     service_name = string
#   })
# }

# Artifact RegistryのID
variable "gar_repository_id" {
  type = string
}

# snampoのDockerイメージ
variable "snampo_be_image" {
  type    = string
  default = "snampo/snampo-be-dev"
}
