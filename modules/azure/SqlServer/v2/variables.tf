variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "location" {
  type = string
}

variable "resource_group_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "admin_group_id" {
  type = string
}

variable "admin_group" {
  type = string
}