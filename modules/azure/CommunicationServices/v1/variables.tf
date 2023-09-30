
variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "data_location" {
  type = string
}

variable "public_dns_zone_id" {
  type = string
}

variable "email_senders" {
  default = {}
}

variable "email" {
  default = true
}
