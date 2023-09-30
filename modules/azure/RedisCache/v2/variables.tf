variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "sku" {
  default = "Standard"
  type    = string
}

variable "capacity" {
  default = 1
}

variable "enable_non_ssl_port" {
  default = false
}

variable "resource_group_id" {
  type = string
}

variable "family" {
  default = "C"
}

variable "subnet_id" {
  type = string
}
