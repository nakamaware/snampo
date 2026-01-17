resource "google_apikeys_key" "basic_key" {
  for_each = {
    for k in var.api_keys : k.id => {
      display_name    = k.display_name
      target_services = k.target_services
    }
  }

  name         = each.key
  display_name = each.value.display_name
  restrictions {
    dynamic "api_targets" {
      for_each = each.value.target_services
      content {
        service = api_targets.value
      }
    }
  }
}
