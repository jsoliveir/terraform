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

variable "tier" {
  default = "Standard"
  type    = string
}


variable "capacity" {
  default = 1
}

variable "resource_group_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "queues" {
  type = list(string)
}