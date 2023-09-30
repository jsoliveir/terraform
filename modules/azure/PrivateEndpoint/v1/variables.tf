variable "tags" {
  type = map(string)
}

variable "suffix" {
  default = ""
}

variable "location" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "private_link_resource_id" {
  type = string
}

variable "private_link_group" {
  type = string
}


variable "private_dns_zone_id" {
  type = string
}


