
variable "group_role_assignments" {
  type = list(object({
    resource_id = string
    group       = string
    role        = string
  }))
  default = []
}

variable "object_role_assignments" {
  type = list(object({
    resource_id = string
    object_id   = string
    role        = string
  }))
  default = []
}
