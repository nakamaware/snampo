output "key_strings" {
  depends_on = [google_apikeys_key.basic_key]
  value = {
    for key in var.api_keys :
    key.id => google_apikeys_key.basic_key["${key.id}"].key_string
  }
}
