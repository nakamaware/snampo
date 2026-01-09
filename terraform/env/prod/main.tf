terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.14.1"
    }
  }
}

locals {
  project_id = "snampo-prod"
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
  project               = local.project_id
  region                = "asia-northeast1"
}

module "snampo_prod" {
  source = "../../modules/common"

  project_id = local.project_id
  # Service Account
  sa_list = [
    {
      id   = "${local.project_id}-terraform"
      desc = "Terraform用サービスアカウント"
    },
  ]
  # Service Accountの権限
  sa_iam_config = [
    {
      email = "${local.project_id}-terraform@${local.project_id}.iam.gserviceaccount.com"
      roles = ["roles/owner"]
    },
  ]
  # Service AccountとGitHubリポジトリの連携（nakamawareが管理するリポジトリ限定）
  sa_gh_repo_bindings = [
    {
      sa_id = "${local.project_id}-terraform"
      repos = ["nakamaware/snampo"]
    },
  ]
  # GCSのバケット
  gcs_bucket_names = ["${local.project_id}-bucket"]
}
