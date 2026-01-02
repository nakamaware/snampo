variable "sa_list" {
  type = list(object({
    id   = string
    desc = string
  }))
  default = []
}
