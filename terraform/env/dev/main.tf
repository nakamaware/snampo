terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>7.15.0"
    }
  }
}

locals {
  env          = "dev"
  project_name = "snampo-dev"
  project_id   = "snampo-480404"
  location     = "asia-northeast1"
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
  project               = local.project_id
  region                = "asia-northeast1"
}

module "snampo_dev" {
  source = "../../modules/common"

  project_env  = local.env
  project_id   = local.project_id
  project_name = local.project_name
  # Apple Maps (目的地検索)。秘密鍵 PEM は Secret Manager へ別途 versions add。
  apple_team_id     = var.apple_team_id
  apple_maps_key_id = var.apple_maps_key_id
  # 有効化するAPI
  api_list = [
    "cloudbuild.googleapis.com", # TODO: GitHub Actionsに移行するため削除予定。
  ]
  # グループの権限
  group_iam_config = [
    {
      email = "gcp-organization-developers@nakamaware.com"
      roles = ["roles/editor"]
    },
  ]
  # GARのリポジトリ
  # 削除予定
  gar_repository_list = [
    {
      id                    = "cloud-run-source-deploy"
      desc                  = "Cloud Run Source Deployments"
      package_name_prefixes = ["snampo"]
    },
  ]
}

variable "apple_team_id" {
  type        = string
  description = "Apple Developer Team ID"
  default     = ""
}

variable "apple_maps_key_id" {
  type        = string
  description = "Apple Maps Key ID"
  default     = ""
}
