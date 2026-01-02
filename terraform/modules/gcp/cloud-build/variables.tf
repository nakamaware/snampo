variable "project_id" {
  type = string
}

variable "location" {
  type    = string
  default = "asia-northeast1"
}

variable "config" {
  type = map(object({
    app_installation_id = string
    gh_pat_id           = string
    repos = list(object({
      name = string
      uri  = string
    }))
  }))
}
