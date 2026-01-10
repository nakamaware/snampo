# API
locals {
  default_api_list = [
    # インフラ用API
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "apikeys.googleapis.com",
    "secretmanager.googleapis.com",
    "sts.googleapis.com",
    "cloudbuild.googleapis.com",  # TODO: GitHub Actionsに移行するため削除予定。
  ]
}

module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2"

  project_id = var.project_id
  activate_apis = concat(
    local.default_api_list,
    var.api_list
  )
}

# Service Account
module "service_account" {
  source     = "../gcp/service-account"
  depends_on = [module.project_services]

  sa_list = var.sa_list
}

# IAM
module "iam_members" {
  source     = "../gcp/iam-member"
  depends_on = [module.service_account]

  project_id     = var.project_id
  grp_iam_config = var.grp_iam_config
  sa_iam_config  = var.sa_iam_config
}

# Workload Identity
# サービスアカウントとレポジトリの連携をする。
module "workload_identity" {
  source     = "../gcp/workload-identity"
  depends_on = [module.service_account]

  project_id = var.project_id
  gh_provider_list = [
    {
      provider_id = "nakamaware"
      desc        = "nakamawareのリポジトリ用のWorkload Identity Provider"
      repo_owner  = "nakamaware"
    }
  ]
  sa_gh_repo_bindings = var.sa_gh_repo_bindings
}

# Cloud Storage
module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  version    = "~> 12.0"
  depends_on = [module.project_services]

  project_id = var.project_id
  names      = var.gcs_bucket_names
  location   = var.location
}

# API Key
module "google_api_keys" {
  source     = "../gcp/api-key"
  depends_on = [module.project_services]

  api_keys = var.api_keys
}

# Secret Manager
module "secret_manager" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.9"
  depends_on = [module.google_api_keys]

  project_id = var.project_id
  # 登録するシークレット
  secrets = concat(
    # APIキー
    [
      for key, val in module.google_api_keys.key_strings : {
        name        = key
        secret_data = val
      }
    ],
    # その他シークレット
    var.secrets
  )
  # シークレットの保管場所
  user_managed_replication = merge(
    {
      for key, val in module.google_api_keys.key_strings : key => [{
        location     = var.location
        kms_key_name = null
      }]
    },
    {
      for s in var.secrets : s.name => [{
        location     = var.location
        kms_key_name = null
      }]
    }
  )
}

# Artifact Registry
module "artifact_registry" {
  source     = "GoogleCloudPlatform/artifact-registry/google"
  version    = "~> 0.8"
  depends_on = [module.project_services]
  for_each = {
    for repo in var.gar_repository_list : repo.id => {
      desc         = repo.desc
      pkg_prefixes = repo.package_name_prefixes
    }
  }

  project_id    = var.project_id
  location      = var.location
  format        = "Docker"
  repository_id = each.key
  description   = each.value.desc
  cleanup_policies = {
    # 7日より前に作成されたイメージは削除
    delete_policy = {
      action = "DELETE"
      condition = {
        older_than            = "7d"
        package_name_prefixes = each.value.pkg_prefixes
      }
    }
    # 最新の10バージョンは残す
    keep_policy = {
      action = "KEEP"
      most_recent_versions = {
        keep_count            = 10
        package_name_prefixes = each.value.pkg_prefixes
      }
    }
  }
}

# Cloud Run Service
module "cloud_run_service" {
  source     = "../gcp/cloud-run"
  depends_on = [module.iam_members, module.secret_manager]
  for_each = {
    for conf in var.cloud_run_service_configs : conf.service_name => {
      service_account = conf.service_account
      container_specs = conf.container_specs
    }
  }

  service_name    = each.key
  service_account = each.value.service_account
  container_specs = each.value.container_specs
}
