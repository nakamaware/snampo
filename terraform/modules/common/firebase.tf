# Firebase (協力プレイモード)
#
# 協力プレイで使う Firebase Auth (匿名)・Firestore・Cloud Storage・App Check・Security Rules を構成する。
# Terraform で管理できないもの (App Check のデバッグトークンの登録など) は docs/coop-play-setup.md を参照。

locals {
  firebase_api_list = [
    "firebase.googleapis.com",
    "identitytoolkit.googleapis.com",
    "firestore.googleapis.com",
    "firebasestorage.googleapis.com",
    "firebaseappcheck.googleapis.com",
    "firebaserules.googleapis.com",
    "firebaseinstallations.googleapis.com",
  ]

  # 協力プレイのデータの保持期限 (ルーム作成から 7 日)
  coop_data_retention_days = 7

  # アプリの識別子 (Android の applicationId / iOS の bundle id)
  app_package_name = "com.nakamaware.snampo"
  apple_team_id    = "B263XJUHQS"

  # Rules のソース (リポジトリルートの firebase/ 配下)
  firebase_rules_dir = "${path.module}/../../../firebase"
}

# Firebase をプロジェクトに追加する
resource "google_firebase_project" "default" {
  provider   = google-beta
  project    = var.project_id
  depends_on = [module.project_services]
}

# アプリの登録
resource "google_firebase_android_app" "snampo" {
  provider      = google-beta
  project       = var.project_id
  display_name  = "snampo (Android)"
  package_name  = local.app_package_name
  sha256_hashes = var.firebase_android_sha256_hashes
  depends_on    = [google_firebase_project.default]
}

resource "google_firebase_apple_app" "snampo" {
  provider     = google-beta
  project      = var.project_id
  display_name = "snampo (iOS)"
  bundle_id    = local.app_package_name
  team_id      = local.apple_team_id
  depends_on   = [google_firebase_project.default]
}

# Firebase Auth (Identity Platform)
resource "google_identity_platform_config" "default" {
  project = var.project_id
  # 将来、同じ uid へ account link して過去の同行者を表示するため、匿名アカウントを自動で消さない
  autodelete_anonymous_users = false

  sign_in {
    anonymous {
      enabled = true
    }
  }

  depends_on = [google_firebase_project.default]
}

# Firestore
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.location
  type        = "FIRESTORE_NATIVE"
  depends_on  = [google_firebase_project.default]
}

# TTL ポリシー (deleteAt を過ぎたドキュメントを自動で削除する)
# TTL はサブコレクションを自動では消さないため、members と clears の collection group にも設定する
resource "google_firestore_field" "coop_ttl" {
  for_each = toset(["rooms", "members", "clears"])

  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = each.key
  field      = "deleteAt"

  ttl_config {}
  # TTL 用のフィールドは検索に使わないので、単一フィールドインデックスを作らない
  index_config {}
}

# Cloud Storage (Always Free の対象リージョンに作る)
resource "google_storage_bucket" "coop" {
  project                     = var.project_id
  name                        = "${var.project_name}-coop"
  location                    = "us-central1"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = local.coop_data_retention_days
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [module.project_services]
}

resource "google_firebase_storage_bucket" "coop" {
  provider   = google-beta
  project    = var.project_id
  bucket_id  = google_storage_bucket.coop.name
  depends_on = [google_firebase_project.default]
}

# Storage の Rules から firestore.get で members を参照するため、
# Firebase Storage のサービスエージェントに Firestore を読む権限を付与する
resource "google_project_service_identity" "firebase_storage" {
  provider   = google-beta
  project    = var.project_id
  service    = "firebasestorage.googleapis.com"
  depends_on = [module.project_services]
}

resource "google_project_iam_member" "firebase_storage_rules_firestore" {
  project = var.project_id
  role    = "roles/firebaserules.firestoreServiceAgent"
  member  = google_project_service_identity.firebase_storage.member
}

# Security Rules
resource "google_firebaserules_ruleset" "firestore" {
  project = var.project_id
  source {
    files {
      name    = "firestore.rules"
      content = file("${local.firebase_rules_dir}/firestore.rules")
    }
  }
  depends_on = [google_firestore_database.default]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_firebaserules_release" "firestore" {
  project      = var.project_id
  name         = "cloud.firestore"
  ruleset_name = google_firebaserules_ruleset.firestore.name

  lifecycle {
    replace_triggered_by = [google_firebaserules_ruleset.firestore]
  }
}

resource "google_firebaserules_ruleset" "storage" {
  project = var.project_id
  source {
    files {
      name    = "storage.rules"
      content = file("${local.firebase_rules_dir}/storage.rules")
    }
  }
  depends_on = [google_firebase_storage_bucket.coop]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_firebaserules_release" "storage" {
  project      = var.project_id
  name         = "firebase.storage/${google_storage_bucket.coop.name}"
  ruleset_name = google_firebaserules_ruleset.storage.name

  lifecycle {
    replace_triggered_by = [google_firebaserules_ruleset.storage]
  }
}

# App Check
resource "google_firebase_app_check_play_integrity_config" "android" {
  project = var.project_id
  app_id  = google_firebase_android_app.snampo.app_id
}

resource "google_firebase_app_check_app_attest_config" "ios" {
  project = var.project_id
  app_id  = google_firebase_apple_app.snampo.app_id
}

# Firestore と Storage への App Check の強制を最初から有効にする
resource "google_firebase_app_check_service_config" "enforced" {
  for_each = toset([
    "firestore.googleapis.com",
    "firebasestorage.googleapis.com",
  ])

  project          = var.project_id
  service_id       = each.key
  enforcement_mode = "ENFORCED"

  depends_on = [
    google_firebase_app_check_play_integrity_config.android,
    google_firebase_app_check_app_attest_config.ios,
  ]
}

# firebase_options_*.dart の更新に使う設定 (いずれも公開値)
data "google_firebase_android_app_config" "snampo" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_android_app.snampo.app_id
}

data "google_firebase_apple_app_config" "snampo" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_apple_app.snampo.app_id
}
