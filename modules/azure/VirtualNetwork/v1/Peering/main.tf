
terraform {
  required_providers {
    azurerm = {
      configuration_aliases = [
        azurerm.source,
        azurerm.remote,
      ]
    }
  }
}

variable "source_network" {
  type = object({
    resource_group_name = string
    name                = string
  })
}
variable "remote_network" {
  type = object({
    resource_group_name = string
    name                = string
  })
}

data "azurerm_virtual_network" "source" {
  resource_group_name = var.source_network.resource_group_name
  name                = var.source_network.name
  provider            = azurerm.source
}

data "azurerm_virtual_network" "remote" {
  resource_group_name = var.remote_network.resource_group_name
  name                = var.remote_network.name
  provider            = azurerm.remote
}

resource "azurerm_virtual_network_peering" "source" {
  remote_virtual_network_id    = data.azurerm_virtual_network.remote.id
  resource_group_name          = var.source_network.resource_group_name
  virtual_network_name         = var.source_network.name
  name                         = var.remote_network.name
  provider                     = azurerm.source
  use_remote_gateways          = false
  allow_gateway_transit        = true
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}


resource "azurerm_virtual_network_peering" "remote" {
  remote_virtual_network_id    = data.azurerm_virtual_network.source.id
  resource_group_name          = var.remote_network.resource_group_name
  virtual_network_name         = var.remote_network.name
  name                         = var.source_network.name
  provider                     = azurerm.remote
  use_remote_gateways          = false
  allow_gateway_transit        = true
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
}
