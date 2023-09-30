variable "subnet_id" {
  type = string
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "image" {
  default = {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
variable "vm_size" {
  default = "Standard_B2s"
}

variable "os_disk_type" {
  default = "Standard_LRS"
}

variable "os_disk_size" {
  default = 50
}

variable "public_ip" {
  type    = bool
  default = true
}

variable "private_ip_address" {
  type = string
}

variable "admin_user" {
  type = string
}

variable "admin_pass" {
  sensitive = true
  type      = string
}

variable "host_name" {
  type = string
}
