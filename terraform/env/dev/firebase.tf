# 協力プレイ用 Firebase。既存 GCP (snampo-480404) に載せる。
# prod にはまだ足さない。App Check のプロバイダは未決なのでここでは作らない。
# メール / Phone Auth は有効にしない。

resource "google_firebase_project" "default" {
  provider = google-beta
  project  = local.project_id

  depends_on = [module.snampo_dev]
}

resource "google_identity_platform_config" "auth" {
  provider = google-beta
  project  = google_firebase_project.default.project

  sign_in {
    anonymous {
      enabled = true
    }
  }
}

resource "google_firestore_database" "default" {
  provider                = google-beta
  project                 = google_firebase_project.default.project
  name                    = "(default)"
  location_id             = local.location
  type                    = "FIRESTORE_NATIVE"
  concurrency_mode        = "OPTIMISTIC"
  delete_protection_state = "DELETE_PROTECTION_ENABLED"
  deletion_policy         = "ABANDON"
}

# tfstate 用 snampo-dev-bucket とは別にする。
resource "google_storage_bucket" "coop_mission" {
  project                     = local.project_id
  name                        = "${local.project_id}-coop-mission"
  location                    = local.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [module.snampo_dev]
}

resource "google_firebase_storage_bucket" "coop_mission" {
  provider  = google-beta
  project   = google_firebase_project.default.project
  bucket_id = google_storage_bucket.coop_mission.name
}

resource "google_firebase_android_app" "default" {
  provider     = google-beta
  project      = google_firebase_project.default.project
  display_name = "snampo"
  package_name = "com.nakamaware.snampo"
}

resource "google_firebase_apple_app" "default" {
  provider     = google-beta
  project      = google_firebase_project.default.project
  display_name = "snampo"
  bundle_id    = "com.nakamaware.snampo"
  team_id      = "B263XJUHQS"
}

resource "google_firebaserules_ruleset" "firestore" {
  provider = google-beta
  project  = google_firestore_database.default.project

  source {
    files {
      name    = "firestore.rules"
      content = file("${path.module}/../../../firebase/firestore.rules")
    }
  }
}

resource "google_firebaserules_release" "firestore" {
  provider     = google-beta
  project      = google_firestore_database.default.project
  name         = "cloud.firestore"
  ruleset_name = google_firebaserules_ruleset.firestore.name
}

resource "google_firebaserules_ruleset" "storage" {
  provider = google-beta
  project  = google_firebase_project.default.project

  source {
    files {
      name    = "storage.rules"
      content = file("${path.module}/../../../firebase/storage.rules")
    }
  }
}

resource "google_firebaserules_release" "storage" {
  provider     = google-beta
  project      = google_firebase_project.default.project
  name         = "firebase.storage/${google_storage_bucket.coop_mission.name}"
  ruleset_name = google_firebaserules_ruleset.storage.name
}
