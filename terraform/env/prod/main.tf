terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>7.15.0"
    }
  }
}

locals {
  project_name = "snampo-prod"
  project_id   = "snampo-prod"
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
  project               = local.project_id
  region                = "asia-northeast1"
}

module "snampo_prod" {
  source = "../../modules/common"

  project_id   = local.project_id
  project_name = local.project_name
  # 有効化するAPI
  api_list = [
    # アプリケーション用API
    "streetviewpublish.googleapis.com",
    "directions-backend.googleapis.com", # TODO: Legacyになったので、Routes APIに置き換える。
    "maps-ios-backend.googleapis.com",
    "maps-android-backend.googleapis.com",
    "maps-backend.googleapis.com",
  ]
  # グループの権限
  group_iam_config = [
    {
      email = "gcp-organization-developers@nakamaware.com"
      roles = ["roles/viewer"]
    },
  ]
}
