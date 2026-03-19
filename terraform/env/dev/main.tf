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

# Cloud Quotas コンソールとの対応
# - サービスID            → service
# - 上限名                → quota_id
# - 名前                  → service + quota_id から自動生成（Terraform からは指定しない）
# - 項目（ロケーション等）→ dimensions
# - 値                    → quota_config.preferred_value
# - 対象プロジェクト      → parent = "projects/<project-id>"

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_directions_api" {
  service  = "directions-backend.googleapis.com"
  quota_id = "BillableDefaultPerDayPerProject"
  parent   = "projects/snampo-480404"
  quota_config {
    preferred_value = 15000
  }
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_new_places_api" {
  service  = "places.googleapis.com"
  quota_id = "SearchNearbyRequestPerDayPerProject"
  parent   = "projects/snampo-480404"
  quota_config {
    preferred_value = 15000
  }
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_roads_api" {
  service  = "roads.googleapis.com"
  quota_id = "BillableDefaultPerDayPerProject"
  parent   = "projects/snampo-480404"
  quota_config {
    preferred_value = 15000
  }
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_street_view_api_from_be" {
  service  = "street-view-image-backend.googleapis.com"
  quota_id = "StreetViewMetadataPerDayPerProject"
  parent   = "projects/snampo-480404"
  quota_config {
    preferred_value = 15000
  }
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_street_view_api_from_app" {
  service  = "street-view-image-backend.googleapis.com"
  quota_id = "BillableUnsignedbucketPerDayPerProject"
  parent   = "projects/snampo-480404"
  quota_config {
    preferred_value = 15000
  }
}
