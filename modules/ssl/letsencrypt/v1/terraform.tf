terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = ">= 2.14.0"
    }
  }
}

provider "acme" {
  server_url = var.server_url
}