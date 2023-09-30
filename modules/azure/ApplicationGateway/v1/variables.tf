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
  default = "Standard_v2"
}

variable "tier" {
  default = "Standard_v2"
}

variable "capacity" {
  default = 1
}

variable "subnet_id" {
  type = string
}

variable "public_ip_sku" {
  default = "Standard"
}

variable "public_ip_idle_timeout_in_minutes" {
  default = 4
}

variable "private_ip_address" {
  type = string
}

variable "listeners" {
  type = map(object({
    backend_host     = optional(string, null)
    backend_pool     = list(string)
    backend_protocol = string
    certificate      = string
    public           = bool
  }))
}

variable "certificates" {
  type    = map(string)
  default = {}
}

variable "firewall_mode" {
  default = "Detection"
}
