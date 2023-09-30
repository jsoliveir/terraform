variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "name" {
  type    = string
}

variable "dns_a_records" {
  type = list(object({
    records = list(string)
    name    = string
    ttl     = number
  }))
  default = []
}

variable "dns_cname_records" {
  type = list(object({
    record = string
    name   = string
    ttl    = number
  }))

  default = []
}

variable "dns_mx_records" {
  type = list(object({
    records    = list(string)
    name       = string
    ttl        = number
  }))
  default = []
}

variable "dns_txt_records" {
  type = list(object({
    records = list(string)
    name    = string
    ttl     = number
  }))

  default = []
}

variable "dns_ns_records" {
  type = list(object({
    records = list(string)
    name    = string
    ttl     = number
  }))

  default = []
}


