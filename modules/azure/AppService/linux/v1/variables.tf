
variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "private" {
  type    = bool
  default = true
}

variable "outbound_subnet_id" {
  description = "the subnet used for outbound network traffic"
  type        = string
  default     = null
}

variable "inbound_subnet_id" {
  description = "the subnet used for inbound network traffic"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  type    = string
  default = null
}

variable "sku" {
  type    = string
  default = "F1"
}

variable "location" {
  type = string
}

variable "sites" {
  type = map(object({
    docker_image    = optional(string, null)
    dotnet_version  = optional(string, null)
    php_version     = optional(string, null)
    app_settings    = optional(map(string), {})
    startup_command = optional(string, null)
    ftp             = optional(bool, true)
    volumes = optional(list(object({
      type                 = optional(string, "AzureBlob")
      storage_account_name = string
      storage_account_key  = string
      resource_group_name  = string
      share_name           = string
      mount_path           = string
    })), [])
    backups = optional(object({
      storage_account_url = string
      retention_days      = number
      interval            = number
    }), null)
  }))

}
