variable "resource_group_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "retention_days" {
  default = 7
}

variable "secrets" {
  type = map(string)
  default = {}
}