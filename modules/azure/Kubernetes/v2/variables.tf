
variable "resource_group_id" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "kubernetes_version" {
  default = "1.24.6"
}

variable "subnet_id" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
  default = "Standard_DS2_v2"
}

variable "node_pools" {
  type = map(object({
    taints    = list(string)
    vm_size   = string
    disk_size = number
    max_nodes = number
    mode      = string
  }))

  validation {
    condition = length([
      for name, _ in var.node_pools : true
      if name == "system"
    ]) == 1
    error_message = "Node pools must have only one system pool."
  }
  
}
