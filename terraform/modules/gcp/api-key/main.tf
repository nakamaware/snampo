resource "google_apikeys_key" "basic_key" {
  for_each = var.api_keys

  name         = each.key
  display_name = each.value.name
  restrictions {
    dynamic "api_targets" {
      for_each = each.value.target_services
      content {
        service = api_targets.value
      }
    }
  }
}
