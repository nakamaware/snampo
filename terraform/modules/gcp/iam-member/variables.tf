variable "project_id" {
  type = string
}

variable "group_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
}

variable "service_account_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
}
