# アプリの dart-define (FIREBASE_*) に登録する Firebase の設定
# 登録手順は docs/coop-play-setup.md を参照
output "firebase_options" {
  value = module.firebase.app_config
}
