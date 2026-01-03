variable "service_name" {
  type = string
}

variable "location" {
  type    = string
  default = "asia-northeast1"
}

# Cloud Runインスタンスが利用するSA
variable "service_account" {
  type = string
}

# コンテナの設定
variable "container_specs" {
  type = object({
    env = list(object({
      name  = string
      value = string
    }))
    env_secret = list(object({
      name      = string
      secret_id = string
    }))
    port = string
  })
}
