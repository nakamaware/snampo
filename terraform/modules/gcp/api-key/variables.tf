variable "api_keys" {
  type = list(object({
    id              = string
    display_name    = string
    target_services = list(string)
  }))
}
