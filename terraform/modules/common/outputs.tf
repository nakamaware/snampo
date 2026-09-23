# firebase_options_*.dart の更新に使う Firebase の設定 (いずれも公開値)
# 更新手順は docs/coop-play-setup.md を参照
output "firebase_options" {
  value = module.firebase.app_config
}
