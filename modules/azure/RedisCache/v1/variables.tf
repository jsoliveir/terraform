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

variable "sku" {
  default = "Standard"
}

variable "capacity" {
  default = 1
}

variable "subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "enable_non_ssl_port" {
  default = true
}

variable "family" {
  default = "C"
}

variable "allow_network_cidrs" {
  default = [
    "10.0.0.0/8"
  ]
}

