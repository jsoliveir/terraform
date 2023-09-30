variable "custom_domains" {
  type = map(object({
    dns_zone_resource_group = string
    dns_zone_subscription   = string
  }))
  default = {}
}

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

variable "sku" {
  default = "Standard"
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}
