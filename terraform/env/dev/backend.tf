terraform {
  backend "gcs" {
    bucket = "snampo-dev-bucket"
    prefix = "terraform/state"
  }
}
