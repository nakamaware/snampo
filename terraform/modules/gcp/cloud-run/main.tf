
resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.location
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"

  scaling {
    max_instance_count = 3
  }

  template {
    containers {
      image = var.image_link
    }
  }
}
