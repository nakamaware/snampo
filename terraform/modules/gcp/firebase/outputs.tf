# アプリの Firebase の設定 (いずれも公開値)
output "app_config" {
  value = {
    project_id          = var.project_id
    messaging_sender_id = google_firebase_project.default.project_number
    storage_bucket      = var.storage_bucket
    android_app_id      = google_firebase_android_app.default.app_id
    ios_app_id          = google_firebase_apple_app.default.app_id
    ios_bundle_id       = google_firebase_apple_app.default.bundle_id
    # api_key は google-services.json (Android) と GoogleService-Info.plist (iOS) に含まれる
    android_config_json = base64decode(data.google_firebase_android_app_config.default.config_file_contents)
    ios_config_plist    = base64decode(data.google_firebase_apple_app_config.default.config_file_contents)
  }
}
