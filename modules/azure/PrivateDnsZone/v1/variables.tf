variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "virtual_network_ids" {
  type = list(string)
  default = []
}

variable "name" {
  type = string
}

variable "dns_a_records" {
  type = list(object({
    records  = list(string)
    name = string
    ttl  = number
  }))
}

variable "dns_cname_records" {
  type = list(object({
    record  = string
    name = string
    ttl  = number
  }))
}
