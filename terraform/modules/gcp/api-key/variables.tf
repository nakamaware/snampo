variable "api_keys" {
  type = map(object({
    name            = string
    target_services = list(string)
  }))
}
