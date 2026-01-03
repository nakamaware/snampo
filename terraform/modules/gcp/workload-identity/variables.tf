variable "project_id" {
  type = string
}

variable "pool_list" {
  type = list(object({
    id   = string
    desc = string
  }))
  default = []
}

variable "gh_provider_list" {
  type = list(object({
    provider_id = string
    desc        = string
    repo_owner  = string
  }))
  default = []
}

variable "sa_gh_repo_bindings" {
  type = list(object({
    sa_id = string
    repos = list(string)
  }))
  default = []
}
