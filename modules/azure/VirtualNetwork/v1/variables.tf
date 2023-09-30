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

variable "subnets" {
  type = map(string)
}

variable "subnet_delegations" {
  type    = map(list(string))
  default = {}
}


variable "security_rules" {
  type = map(object({
    destination_address_prefix = optional(string,null)
    source_address_prefix      = optional(string,null)
    access                     = string
    destination_port_range     = string
  }))
  default = {}
}

variable "peerings" {
  type    = map(string)
  default = {}
}

variable "private_dns_zones" {
  type    = list(string)
  default = []
}

variable "service_endpoints" {
  type    = list(string)
  default = []
}

