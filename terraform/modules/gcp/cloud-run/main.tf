
resource "google_cloud_run_v2_service" "default" {
  name                 = var.service_name
  location             = var.location
  invoker_iam_disabled = true
  deletion_protection  = false

  scaling {
    max_instance_count = 3
  }

  template {
    service_account = var.service_account
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      # 環境変数
      dynamic "env" {
        for_each = { for e in var.container_specs.env : e.name => e.value }
        content {
          name  = env.key
          value = env.value
        }
      }
      # シークレット
      dynamic "env" {
        for_each = { for s in var.container_specs.env_secret : s.name => s.secret_id }
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }
      # 公開するポート
      ports {
        container_port = var.container_specs.port
      }
    }
  }

  lifecycle {
    ignore_changes = [
      client,
      client_version,
      template[0].labels,
      template[0].containers[0].image
    ]
  }
}
