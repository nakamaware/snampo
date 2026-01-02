output "key_strings" {
  value = {
    for key, _ in var.api_keys:
      key => google_apikeys_key.basic_key["${key}"].key_string
  }
}
