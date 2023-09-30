variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "subnets" {
  type = map(string)
}

variable "subnet_delegations" {
  type = map(string)
}

variable "security_rules" {
  type = map(object({
    access                     = string
    destination_port_range     = string
    destination_address_prefix = string
  }))
  default = {}
}
