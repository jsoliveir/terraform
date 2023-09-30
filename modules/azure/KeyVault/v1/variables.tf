variable "resource_group_name" {
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

variable "copy_from" {
  default = []
  type = list(object({
    subscription = string
    resource_group = string
    keyvault= string
    secret = string
    name = string
  }))
}

variable "certificates" {
  default = {}
  type = map(object({
    data = string
    password = string
  }))
  
}