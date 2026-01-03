variable "project_id" {
  type = string
}

variable "grp_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
}

variable "sa_iam_config" {
  type = list(object({
    email = string
    roles = list(string)
  }))
}
