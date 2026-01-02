locals {
  _repo_configs = flatten([
    for conn_key, conn_val in var.config : [
      for repo in conn_val.repos : {
        conn_name = conn_key
        repo_name = repo.name
        repo_uri  = repo.uri
      }
    ]
  ])

  repo_config_map = {
    for config in local._repo_configs : config.repo_name => {
      conn_name = config.conn_name
      uri       = config.repo_uri
    }
  }
}

resource "google_cloudbuildv2_connection" "connection" {
  project  = var.project_id
  location = var.location

  for_each = var.config
  name     = each.key
  github_config {
    app_installation_id = each.value.app_installation_id
    authorizer_credential {
      oauth_token_secret_version = each.value.gh_pat_id
    }
  }
}

resource "google_cloudbuildv2_repository" "repository" {
  depends_on = [google_cloudbuildv2_connection.connection]
  project    = var.project_id
  location   = var.location

  for_each          = local.repo_config_map
  name              = each.key
  parent_connection = google_cloudbuildv2_connection.connection["${each.value.conn_name}"].name
  remote_uri        = each.value.uri
}
