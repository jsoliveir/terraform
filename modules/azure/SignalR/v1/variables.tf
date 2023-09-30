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
  default = "Free_F1"
}

variable "capacity" {
  default = 1
}

variable "private_dns_zone_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "entrypoint" {
  type = string
}
