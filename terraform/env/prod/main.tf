terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>7.15.0"
    }
  }
}

locals {
  env          = "prod"
  project_name = "snampo-prod"
  project_id   = "snampo-prod"
}

provider "google" {
  user_project_override = true
  billing_project       = local.project_id
  project               = local.project_id
  region                = "asia-northeast1"
}

module "snampo_prod" {
  source = "../../modules/common"

  project_env  = local.env
  project_id   = local.project_id
  project_name = local.project_name
  # Apple Maps (目的地検索)。秘密鍵 PEM は Secret Manager へ別途 versions add。
  apple_team_id     = var.apple_team_id
  apple_maps_key_id = var.apple_maps_key_id
  # グループの権限
  group_iam_config = [
    {
      email = "gcp-organization-developers@nakamaware.com"
      roles = ["roles/viewer"]
    },
  ]
}

variable "apple_team_id" {
  type        = string
  description = "Apple Developer Team ID"
  default     = ""
}

variable "apple_maps_key_id" {
  type        = string
  description = "Apple Maps Key ID"
  default     = ""
}
