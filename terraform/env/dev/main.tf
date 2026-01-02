terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.14.1"
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

  project_id          = local.project_id
  # Secret Managerに登録するsecret
  # secrets = [
  #   {
  #     name = "github_token",
  #     secret_data = var.github_token_secret
  #   }
  # ]
  # Service Account
  sa_list = [
    {
      id   = "snampo-dev-cicd"
      desc = "CI/CD用サービスアカウント"
    },
    {
      id   = "snampo-dev-terraform"
      desc = "Terraform用サービスアカウント"
    }
  ]
  # グループの権限
  grp_iam_config = [
    {
      email = "gcp-organization-developers@nakamaware.com"
      roles = ["roles/editor"]
    }
  ]
  # Service Accountの権限
  sa_iam_config = [
    {
      email = "snampo-dev-cicd@snampo-480404.iam.gserviceaccount.com"
      roles = ["roles/artifactregistry.writer"]
    },
    {
      email = "snampo-dev-terraform@snampo-480404.iam.gserviceaccount.com"
      roles = ["roles/owner"]
    }
  ]
  # Service AccountとGitHubリポジトリの連携
  sa_gh_repo_bindings = [
    {
      sa_id = "snampo-dev-cicd"
      repos = ["nakamaware/snampo"]
    },
    {
      sa_id = "snampo-dev-terraform"
      repos = ["nakamaware/snampo"]
    }
  ]
  # GCSのバケット
  gcs_bucket_names  = ["${local.project_name}-bucket"]
  # GARのリポジトリ
  gar_repository_id = "cloud-run-source-deploy"
}
