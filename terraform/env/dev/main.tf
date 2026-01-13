terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>7.15.0"
    }
  }
}

locals {
  project_name = "snampo-dev"
  project_id   = "snampo-480404"
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
  project               = local.project_id
  region                = "asia-northeast1"
}

module "snampo_dev" {
  source = "../../modules/common"

  project_id   = local.project_id
  project_name = local.project_name
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
