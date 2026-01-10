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

  project_id = local.project_id
  # 有効化するAPI
  api_list = [
    # アプリケーション用API
    "streetviewpublish.googleapis.com",
    "directions-backend.googleapis.com", # TODO: Legacyになったので、Routes APIに置き換える。
    "maps-ios-backend.googleapis.com",
    "maps-android-backend.googleapis.com",
    "maps-backend.googleapis.com",
  ]
  # 作成するAPIキー
  api_keys = [
    # TODO: これ消して、実際に利用するAPIキーを作成する
    {
      id           = "google-api-key"
      display_name = "google-api-key"
      target_services = [
        "streetviewpublish.googleapis.com",
        "directions-backend.googleapis.com",
      ]
    },
  ]
  # Service Account
  sa_list = [
    {
      id   = "${local.project_name}-run"
      desc = "Cloud Run用サービスアカウント"
    },
    {
      id   = "${local.project_name}-cicd"
      desc = "CI/CD用サービスアカウント"
    },
    {
      id   = "${local.project_name}-terraform"
      desc = "Terraform用サービスアカウント"
    },
  ]
  # グループの権限
  grp_iam_config = [
    {
      email = "gcp-organization-developers@nakamaware.com"
      roles = ["roles/editor"]
    },
  ]
  # Service Accountの権限
  sa_iam_config = [
    {
      email = "${local.project_name}-run@snampo-480404.iam.gserviceaccount.com"
      roles = [
        "roles/secretmanager.secretAccessor",
        "roles/logging.logWriter",
      ]
    },
    {
      email = "${local.project_name}-cicd@snampo-480404.iam.gserviceaccount.com"
      roles = [
        "roles/artifactregistry.writer",
        "roles/run.developer",
        "roles/iam.serviceAccountUser",
      ]
    },
    {
      email = "${local.project_name}-terraform@snampo-480404.iam.gserviceaccount.com"
      roles = ["roles/owner"]
    },
  ]
  # Service AccountとGitHubリポジトリの連携（nakamawareが管理するリポジトリ限定）
  sa_gh_repo_bindings = [
    {
      sa_id = "${local.project_name}-cicd"
      repos = ["nakamaware/snampo"]
    },
    {
      sa_id = "${local.project_name}-terraform"
      repos = ["nakamaware/snampo"]
    },
  ]
  # GCSのバケット
  gcs_bucket_names = ["${local.project_name}-bucket"]
  # GARのリポジトリ
  gar_repository_list = [
    {
      id                    = "cloud-run-source-deploy"
      desc                  = "Cloud Run Source Deployments"
      package_name_prefixes = ["snampo"]
    },
    {
      id                    = "snampo-dev"
      desc                  = "Cloud Run Source Deployments"
      package_name_prefixes = ["snampo"]
    },
  ]
  # Cloud Run Service
  cloud_run_service_configs = [
    {
      service_name    = "test-${local.project_name}-be"
      service_account = "${local.project_name}-run@snampo-480404.iam.gserviceaccount.com"
      container_specs = {
        env = []
        env_secret = [
          {
            name      = "GOOGLE_API_KEY"
            secret_id = "google-api-key"
          },
        ] # ここで指定できるのは、APIキーかシークレットのID
        port = 80
      }
    }
  ]
}
