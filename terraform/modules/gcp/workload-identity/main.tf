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
locals {
  # GitHubリポジトリに付与する権限
  _roles = [
    "roles/iam.workloadIdentityUser",
    "roles/iam.serviceAccountTokenCreator"
  ]

  _sa_gh_binding_list = flatten([
    for b in var.sa_gh_repo_bindings : [
      for r in local._roles : {
        sa_id = b.sa_id
        role  = r
        repos = b.repos
      }
    ]
  ])

  sa_gh_bindings_map = {
    for b in local._sa_gh_binding_list : "${b.sa_id}:${b.role}" => {
      sa_id = b.sa_id
      role  = b.role
      repos = b.repos
    }
  }
}

data "google_service_account" "service_account" {
  for_each = toset([for b in var.sa_gh_repo_bindings : b.sa_id])

  project    = var.project_id
  account_id = each.value
}

resource "google_service_account_iam_binding" "sa_gh_binding" {
  depends_on = [google_iam_workload_identity_pool.pool]
  for_each   = local.sa_gh_bindings_map

  service_account_id = data.google_service_account.service_account["${each.value.sa_id}"].name
  role               = each.value.role
  members = [
    for repo in each.value.repos :
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool["github"].name}/attribute.repository/${repo}"
  ]
}
