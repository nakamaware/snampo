terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "7.14.1"
    }
  }
}

locals {
  project_id = "snampo-prod"
}

provider "google" {
  project = local.project_id
}

# TODO: 共通モジュールでリソースを定義する