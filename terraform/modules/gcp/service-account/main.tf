resource "google_service_account" "service_accounts" {
  for_each = {
    for sa in var.service_account_list : sa.id => {
      id = sa.id
      name = sa.id
      desc = sa.desc
    }
  }
  account_id   = each.value.id
  display_name = each.value.name
  description  = each.value.desc
}
