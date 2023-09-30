variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "sku" {
  default = "Free"
}

variable "name" {
  default = "ntfns-01"
}

variable "hubs" {
  type = list(string)
}

variable "private_dns_zone_id" {
  type = string
  default = null
}

variable "subnet_id" {
  type = string
  default = null
}

variable "create_private_endpoint" {
  default =  true
}