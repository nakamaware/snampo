# Firebase (Auth 匿名・Firestore・Cloud Storage の紐付け・Security Rules・App Check)
#
# 推奨設定はハードコーディングし、プロジェクトによって変わる設定は変数で受け取る。
# Terraform で管理できないもの (App Check のデバッグトークンの登録など) は docs/coop-play-setup.md を参照。

# Firebase をプロジェクトに追加する
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

# アプリの登録
resource "google_firebase_android_app" "default" {
  provider      = google-beta
  project       = var.project_id
  display_name  = "${var.app_display_name} (Android)"
  package_name  = var.android_package_name
  sha256_hashes = var.android_sha256_hashes
  depends_on    = [google_firebase_project.default]
}

resource "google_firebase_apple_app" "default" {
  provider     = google-beta
  project      = var.project_id
  display_name = "${var.app_display_name} (iOS)"
  bundle_id    = var.apple_bundle_id
  team_id      = var.apple_team_id
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
  location_id = var.firestore_location
  type        = "FIRESTORE_NATIVE"
  depends_on  = [google_firebase_project.default]
}

# TTL ポリシー (指定したフィールドの時刻を過ぎたドキュメントを自動で削除する)
# TTL はサブコレクションを自動では消さないため、collection group ごとに設定する
resource "google_firestore_field" "ttl" {
  for_each = {
    for t in var.firestore_ttl_fields : "${t.collection_group}.${t.field}" => t
  }

  project    = var.project_id
  database   = google_firestore_database.default.name
  collection = each.value.collection_group
  field      = each.value.field

  ttl_config {}
  # TTL 用のフィールドは検索に使わないので、単一フィールドインデックスを作らない
  index_config {}
}

# Cloud Storage のバケットを Firebase に紐付ける
resource "google_firebase_storage_bucket" "default" {
  provider   = google-beta
  project    = var.project_id
  bucket_id  = var.storage_bucket
  depends_on = [google_firebase_project.default]
}

# Storage の Rules から firestore.get / exists を使うため、
# Firebase Storage のサービスエージェントに Firestore を読む権限を付与する
resource "google_project_service_identity" "firebase_storage" {
  provider = google-beta
  project  = var.project_id
  service  = "firebasestorage.googleapis.com"
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
      content = var.firestore_rules
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
      content = var.storage_rules
    }
  }
  depends_on = [google_firebase_storage_bucket.default]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_firebaserules_release" "storage" {
  project      = var.project_id
  name         = "firebase.storage/${var.storage_bucket}"
  ruleset_name = google_firebaserules_ruleset.storage.name

  lifecycle {
    replace_triggered_by = [google_firebaserules_ruleset.storage]
  }
}

# App Check (Android は Play Integrity、iOS は App Attest)
resource "google_firebase_app_check_play_integrity_config" "android" {
  project = var.project_id
  app_id  = google_firebase_android_app.default.app_id
}

resource "google_firebase_app_check_app_attest_config" "ios" {
  project = var.project_id
  app_id  = google_firebase_apple_app.default.app_id
}

# App Check の強制を最初から有効にする
resource "google_firebase_app_check_service_config" "enforced" {
  for_each = toset(var.app_check_enforced_services)

  project          = var.project_id
  service_id       = each.key
  enforcement_mode = "ENFORCED"

  depends_on = [
    google_firebase_app_check_play_integrity_config.android,
    google_firebase_app_check_app_attest_config.ios,
  ]
}

# アプリの設定 (公開値)
data "google_firebase_android_app_config" "default" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_android_app.default.app_id
}

data "google_firebase_apple_app_config" "default" {
  provider = google-beta
  project  = var.project_id
  app_id   = google_firebase_apple_app.default.app_id
}
