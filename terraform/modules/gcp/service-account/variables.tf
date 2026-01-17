variable "service_account_list" {
  type = list(object({
    id   = string
    desc = string
  }))
  default = []
}
