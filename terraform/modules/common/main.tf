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
    # バックエンド用API
    "places.googleapis.com",
    "street-view-image-backend.googleapis.com",
    "directions-backend.googleapis.com", # TODO: Legacyになったので、Routes APIに置き換える。
    # フロントエンド用API
    "maps-ios-backend.googleapis.com",
    "maps-android-backend.googleapis.com",
    "maps-backend.googleapis.com",
  ]
}

module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 18.2"

  project_id = var.project_id
  activate_apis = concat(
    local.default_api_list,
    var.api_list,
  )
}

# tfstate用Cloud Storage
locals {
  default_gcs_bucket_names = ["${var.project_name}-bucket"]
}

module "gcs_buckets" {
  source     = "terraform-google-modules/cloud-storage/google"
  version    = "~> 12.0"
  depends_on = [module.project_services]

  project_id = var.project_id
  names      = local.default_gcs_bucket_names
  location   = var.location
}

# Service Account
locals {
  default_service_account_list = [
    {
      id   = "${var.project_name}-run"
      desc = "Cloud Run用サービスアカウント"
    },
    {
      id   = "${var.project_name}-cicd"
      desc = "CI/CD用サービスアカウント"
    },
    {
      id   = "${var.project_name}-terraform"
      desc = "Terraform用サービスアカウント"
    },
  ]
}

module "service_account" {
  source     = "../gcp/service-account"
  depends_on = [module.project_services]

  service_account_list = concat(
    local.default_service_account_list,
    var.service_account_list,
  )
}

# IAM
locals {
  default_group_iam_config = []
  default_service_account_iam_config = [
    {
      email = "${var.project_name}-run@${var.project_id}.iam.gserviceaccount.com"
      roles = [
        "roles/secretmanager.secretAccessor",
        "roles/logging.logWriter",
      ]
    },
    {
      email = "${var.project_name}-cicd@${var.project_id}.iam.gserviceaccount.com"
      roles = [
        "roles/artifactregistry.writer",
        "roles/run.developer",
        "roles/iam.serviceAccountUser",
      ]
    },
    {
      email = "${var.project_name}-terraform@${var.project_id}.iam.gserviceaccount.com"
      roles = [
        "roles/editor",
        "roles/resourcemanager.projectIamAdmin",
        "roles/owner",
      ]
    },
  ]
}

module "iam_members" {
  source     = "../gcp/iam-member"
  depends_on = [module.service_account]

  project_id = var.project_id
  group_iam_config = concat(
    local.default_group_iam_config,
    var.group_iam_config,
  )
  service_account_iam_config = concat(
    local.default_service_account_iam_config,
    var.service_account_iam_config,
  )
}

# Workload Identity
# サービスアカウントとレポジトリの連携をする。
locals {
  default_sa_gh_repo_binding_list = [
    {
      sa_id = "${var.project_name}-cicd"
      repos = ["nakamaware/snampo"]
    },
    {
      sa_id = "${var.project_name}-terraform"
      repos = ["nakamaware/snampo"]
    },
  ]
}

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
  sa_gh_repo_bindings = concat(
    local.default_sa_gh_repo_binding_list,
    var.sa_gh_repo_binding_list,
  )
}

# API Key
locals {
  default_api_key_list = [
    {
      id           = "backend-api-key"
      display_name = "backend-api-key"
      target_services = [
        "places.googleapis.com",
        "street-view-image-backend.googleapis.com",
        "directions-backend.googleapis.com",
      ]
    },
    {
      id           = "frontend-api-key"
      display_name = "frontend-api-key"
      target_services = [
        "maps-ios-backend.googleapis.com",
        "maps-android-backend.googleapis.com",
        "maps-backend.googleapis.com",
      ]
    },
  ]
}

module "google_api_keys" {
  source     = "../gcp/api-key"
  depends_on = [module.project_services]

  api_keys = concat(
    local.default_api_key_list,
    var.api_keys
  )
}

# Secret Manager
module "secret_manager" {
  source     = "GoogleCloudPlatform/secret-manager/google"
  version    = "~> 0.9"
  depends_on = [module.google_api_keys]

  project_id = var.project_id
  # 登録するシークレット（APIキーに限定）
  secrets = [
    for key, val in module.google_api_keys.key_strings : {
      name        = key
      secret_data = val
    }
  ]
  # シークレットの保管場所
  user_managed_replication = {
    for key, val in module.google_api_keys.key_strings : key => [{
      location     = var.location
      kms_key_name = null
    }]
  }
}

# Artifact Registry
locals {
  default_gar_repository_list = [
    {
      id                    = var.project_name
      desc                  = "Cloud Run Source Deployments"
      package_name_prefixes = ["snampo"]
    },
  ]

  gar_repository_list = concat(
    local.default_gar_repository_list,
    var.gar_repository_list
  )
}

module "artifact_registry" {
  source     = "GoogleCloudPlatform/artifact-registry/google"
  version    = "~> 0.8"
  depends_on = [module.project_services]
  for_each = {
    for repo in local.gar_repository_list : repo.id => {
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
locals {
  default_cloud_run_service_config_list = [
    {
      service_name    = "${var.project_name}-backend"
      service_account = "${var.project_name}-run@${var.project_id}.iam.gserviceaccount.com"
      container_specs = {
        env = []
        env_secret = [
          {
            name      = "GOOGLE_API_KEY"
            secret_id = "backend-api-key"
          },
        ] # ここで指定できるのは、APIキーかシークレットのID
        port = 80
      }
    }
  ]

  cloud_run_service_config_list = concat(
    local.default_cloud_run_service_config_list,
    var.cloud_run_service_configs,
  )
}

module "cloud_run_service" {
  source     = "../gcp/cloud-run"
  depends_on = [module.iam_members, module.secret_manager]
  for_each = {
    for conf in local.cloud_run_service_config_list : conf.service_name => {
      service_account = conf.service_account
      container_specs = conf.container_specs
    }
  }

  service_name    = each.key
  service_account = each.value.service_account
  container_specs = each.value.container_specs
}
