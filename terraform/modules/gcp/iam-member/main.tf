locals {
  _grp_conf = flatten([
    for m in var.grp_iam_config : [
      for r in m.roles : {
        project = var.project_id
        role    = r
        member  = m.email
      }
    ]
  ])

  _sa_conf = flatten([
    for m in var.sa_iam_config : [
      for r in m.roles : {
        project = var.project_id
        role    = r
        member  = m.email
      }
    ]
  ])

  grp_map = {
    for conf in local._grp_conf : "${conf.member}:${conf.role}" => {
      project = conf.project
      role    = conf.role
      member  = conf.member
    }
  }

  sa_map = {
    for conf in local._sa_conf : "${conf.member}:${conf.role}" => {
      project = conf.project
      role    = conf.role
      member  = conf.member
    }
  }
}

resource "google_project_iam_member" "group_members" {
  for_each = local.grp_map
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
