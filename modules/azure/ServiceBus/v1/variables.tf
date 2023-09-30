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

variable "queues" {
  type = map(object({
    max_delivery_count                   = number
    max_size_in_megabytes                = number
    dead_lettering_on_message_expiration = bool
    default_message_ttl                  = string
  }))
  default = {}
}

variable "sku" {
  default = "Standard"
}

variable "subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}