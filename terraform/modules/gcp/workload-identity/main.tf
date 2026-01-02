locals {
  pool_list = concat(
    # デフォルトで作成するWorkload Identity Pool
    [
      {
        id   = "github"
        desc = "GitHub Actions Pool"
      },
    ],
    var.pool_list
  )
}

# Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" {
  for_each = { for p in local.pool_list : p.id => p.desc }

  workload_identity_pool_id = each.key
  display_name              = each.key
  description               = each.value
}

# GitHub用のWorkload Identity Provider
resource "google_iam_workload_identity_pool_provider" "gh_provider" {
  depends_on = [google_iam_workload_identity_pool.pool]
  for_each = {
    for p in var.gh_provider_list : p.provider_id => {
      desc       = p.desc
      repo_owner = p.repo_owner
    }
  }

  workload_identity_pool_id          = google_iam_workload_identity_pool.pool["github"].workload_identity_pool_id
  workload_identity_pool_provider_id = each.key
  display_name                       = each.key
  description                        = each.value.desc
  attribute_condition                = "assertion.repository_owner == '${each.value.repo_owner}'"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# GitHubリポジトリとサービスアカウントの連携
data "google_service_account" "service_account" {
  for_each   = toset([for b in var.sa_gh_repo_bindings : b.sa_id])
  
  project    = var.project_id
  account_id = each.value
}

resource "google_service_account_iam_binding" "sa_gh_binding" {
  depends_on = [google_iam_workload_identity_pool.pool]
  for_each           = { for b in var.sa_gh_repo_bindings : b.sa_id => b.repos }

  service_account_id = data.google_service_account.service_account["${each.key}"].name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    for repo in each.value :
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool["github"].name}/attribute.repository/${repo}"
  ]
}
