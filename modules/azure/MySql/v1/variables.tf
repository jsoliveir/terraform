variable "resource_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "databases" {
  type    = list(string)
  default = []
}

variable "backup_retention_days" {
  default = 7
}

variable "platform_version" {
  default = "5.7"
}

variable "sku" {
  default = "B_Standard_B1s"
}

variable "storage_size" {
  default = 20
}

variable "auto_grow_enabled" {
  default = false
}

variable "admin_password" {
  type = string
}

variable "admin_username" {
  type = string
}


variable "firewall_rules" {
  type = map(object({
    start = string
    end   = string
  }))
}
