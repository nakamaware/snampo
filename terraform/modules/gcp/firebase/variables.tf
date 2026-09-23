# リソースを作成するプロジェクトのID
variable "project_id" {
  type = string
}

# Firestoreのロケーション
variable "firestore_location" {
  type    = string
  default = "asia-northeast1"
}

# Firebaseに紐付けるCloud Storageのバケット名
variable "storage_bucket" {
  type = string
}

# Firebaseに登録するアプリの表示名
variable "app_display_name" {
  type = string
}

# Androidのパッケージ名 (applicationId)
variable "android_package_name" {
  type = string
}

# Androidアプリの署名証明書のSHA-256 (Play Integrity用)
variable "android_sha256_hashes" {
  type    = list(string)
  default = []
}

# iOSのbundle id
variable "apple_bundle_id" {
  type = string
}

# iOSのTeam ID (App Attest用)
variable "apple_team_id" {
  type = string
}

# TTLポリシーを設定するフィールド (collection groupごと)
variable "firestore_ttl_fields" {
  type = list(object({
    collection_group = string
    field            = string
  }))
  default = []
}

# FirestoreのSecurity Rulesのソース
variable "firestore_rules" {
  type = string
}

# Cloud StorageのSecurity Rulesのソース
variable "storage_rules" {
  type = string
}

# App Checkを強制するサービス
variable "app_check_enforced_services" {
  type = list(string)
  default = [
    "firestore.googleapis.com",
    "firebasestorage.googleapis.com",
  ]
}
