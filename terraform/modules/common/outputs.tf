# firebase_options_*.dart の更新に使う Firebase の設定 (いずれも公開値)
# 更新手順は docs/coop-play-setup.md を参照
output "firebase_options" {
  value = {
    project_id          = var.project_id
    messaging_sender_id = google_firebase_project.default.project_number
    storage_bucket      = google_storage_bucket.coop.name
    android_app_id      = google_firebase_android_app.snampo.app_id
    ios_app_id          = google_firebase_apple_app.snampo.app_id
    ios_bundle_id       = google_firebase_apple_app.snampo.bundle_id
    # api_key は google-services.json (Android) と GoogleService-Info.plist (iOS) に含まれる
    android_config_json = base64decode(data.google_firebase_android_app_config.snampo.config_file_contents)
    ios_config_plist    = base64decode(data.google_firebase_apple_app_config.snampo.config_file_contents)
  }
}
