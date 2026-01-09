terraform {
  backend "gcs" {
    bucket = "snampo-prod-bucket"
    prefix = "terraform/state"
  }
}
