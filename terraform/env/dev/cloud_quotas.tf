# Cloud Quotas コンソールとの対応
# - サービスID            → service
# - 上限名                → quota_id
# - 名前                  → service + quota_id から自動生成 (Terraform からは指定しない)
# - 項目 (ロケーション等) → dimensions
# - 値                    → quota_config.preferred_value
# - 対象プロジェクト      → parent = "projects/<project-id>"

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_directions_api" {
  depends_on = [module.snampo_dev]

  service  = "directions-backend.googleapis.com"
  quota_id = "BillableDefaultPerDayPerProject"
  parent   = "projects/${local.project_id}"

  quota_config {
    preferred_value = 320
  }

  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_new_places_api" {
  depends_on = [module.snampo_dev]

  service  = "places.googleapis.com"
  quota_id = "SearchNearbyRequestPerDayPerProject"
  parent   = "projects/${local.project_id}"

  quota_config {
    preferred_value = 160
  }

  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_roads_api" {
  depends_on = [module.snampo_dev]

  service  = "roads.googleapis.com"
  quota_id = "BillableDefaultPerDayPerProject"
  parent   = "projects/${local.project_id}"

  quota_config {
    preferred_value = 160
  }

  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_street_view_metadata_api" {
  depends_on = [module.snampo_dev]

  service  = "street-view-image-backend.googleapis.com"
  quota_id = "StreetViewMetadataPerDayPerProject"
  parent   = "projects/${local.project_id}"

  quota_config {
    preferred_value = 1000
  }

  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}

resource "google_cloud_quotas_quota_preference" "overall_rate_limit_for_street_view_static_api" {
  depends_on = [module.snampo_dev]

  service  = "street-view-image-backend.googleapis.com"
  quota_id = "BillableUnsignedbucketPerDayPerProject"
  parent   = "projects/${local.project_id}"

  quota_config {
    preferred_value = 320
  }

  ignore_safety_checks = "QUOTA_DECREASE_PERCENTAGE_TOO_HIGH"
}
