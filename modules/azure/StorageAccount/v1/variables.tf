
variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "allowed_subnets" {
  type    = list(string)
  default = []
}

variable "private_dns_zone_blob_id" {
  type    = string
  default = null
}

variable "private_dns_zone_file_id" {
  type    = string
  default = null
}

variable "allowed_ips" {
  type    = list(string)
  default = []
}

variable "double_encryption_enabled" {
  default = false
}

variable "account_replication_type" {
  default = "LRS"
}

variable "datalake" {
  default = false
}

variable "nfsv3" {
  default = false
}

variable "account_tier" {
  default = "Hot"
}
variable "account_kind" {
  default = "StorageV2"
}

variable "access_tier" {
  default = "Standard"
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "private" {
  type    = string
  default = true
}

variable "containers" {
  type    = list(string)
  default = []
}

variable "shares" {
  type    = list(object({
    name = string
    size = number
  }))
  default = []
}

variable "custom_domain" {
  type    = string
  default = null
}

variable "static_website" {
  default = false
}

