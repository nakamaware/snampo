locals {
  _group_config_list = flatten([
    for m in var.group_iam_config : [
      for r in m.roles : {
        project = var.project_id
        role    = r
        member  = m.email
      }
    ]
  ])

  _service_account_config_list = flatten([
    for m in var.service_account_iam_config : [
      for r in m.roles : {
        project = var.project_id
        role    = r
        member  = m.email
      }
    ]
  ])

  group_map = {
    for config in local._group_config_list : "${config.member}:${config.role}" => {
      project = config.project
      role    = config.role
      member  = config.member
    }
  }

  sa_map = {
    for config in local._service_account_config_list : "${config.member}:${config.role}" => {
      project = config.project
      role    = config.role
      member  = config.member
    }
  }
}

resource "google_project_iam_member" "group_members" {
  for_each = local.group_map
  project  = each.value.project
  role     = each.value.role
  member   = "group:${each.value.member}"
}


resource "google_project_iam_member" "sa_members" {
  for_each = local.sa_map
  project  = each.value.project
  role     = each.value.role
  member   = "serviceAccount:${each.value.member}"
}
