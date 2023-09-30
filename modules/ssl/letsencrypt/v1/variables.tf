variable "server_url" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}
variable "email" {
  type = string
}

variable "domain" {
  type = string
}

variable "account_id" {
  type    = string
  default = null
}

variable "hmac" {
  type    = string
  default = null
}

variable "subdomains" {
  type    = list(string)
  default = []
}

variable "dns_provider" {
  default = "azure"
}

variable "dns_challenge_params" {
  type = map(any)
}

variable "min_days_renewal" {
  default = 30
}

variable "preferred_chain" {
  default = "ISRG Root X1"
}
