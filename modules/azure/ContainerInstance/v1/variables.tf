
variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "image" {
  type = string
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "ports" {
  type = list(object({
    protocol = string
    port     = number
  }))
}

variable "volumes" {
  type = list(object({
    storage_account_name = string
    storage_account_key  = string
    resource_group_name  = string
    share_name           = string
    mount_path           = string
  }))
  default = []
}

variable "subnet_id" {
  description = "make sure the subnet has the Microsoft.ContainerInstance/containerGroups delegation"
  type        = string
  default     = null
}

variable "variables" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type      = map(string)
  sensitive = true
  default   = {}
}

variable "acr_credentials" {
  type = list(object({
    server   = string
    username = string
    password = string
  }))
  default = []
}


variable "private" {
  default = true
}
