
variable "resource_group_name" {
  type = string
}

variable "oidc_issuer_enabled" {
  default = true
}

variable "private_cluster_enabled" {
  default = true
}

variable "public_network_access_enabled" {
  default = false
}

variable "azurerm_container_registry_id" {
  default = null
  type = string
}

variable "sku" {
  default = "Free"
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "kubernetes_version" {
  default = "1.27.1"
}

variable "subnet_id" {
  type = string
}

variable "location" {
  type = string
}

variable "storage" {  
  type = object({
    snapshot_controller_enabled = optional(bool,false)
    blob_driver_enabled = optional(bool,false)
    disk_driver_enabled = optional(bool,true)
    file_driver_enabled = optional(bool,true)
  })
  default = {
    snapshot_controller_enabled = false
    blob_driver_enabled = false
    disk_driver_enabled = true
    file_driver_enabled = true
  }
}

variable "node_pools" {
  type = map(object({
    taints    = list(string)
    vm_size   = string
    disk_size = number
    max_nodes = number
    mode      = string
  }))
}
