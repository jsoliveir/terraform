variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "servers" {
  type = map(object({
    subnet_id = optional(string, null)
    private = optional(bool, false)
    location  = string
  }))
}

variable "databases" {
  type = map(object({
    server = string
    sku    = optional(string, "Basic")
    pool   = optional(string, null)
    size   = optional(number, 2)
  }))
  default = {}
}

variable "database_pools" {
  default = null
  type = map(object({
    tier                     = optional(string, "Basic")
    sku                      = optional(string, "BasicPool")
    max_size_gb              = optional(number, 9.765625)
    per_database_max_capcity = optional(number, 5)
    per_database_min_capcity = optional(number, 5)
    capacity                 = number
    server                   = string
  }))
}

variable "aad_admin_group" {
  type = string
}

variable "private_dns_zone_id" {
  default = null
}
