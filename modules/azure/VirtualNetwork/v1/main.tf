
resource "azurerm_virtual_network" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  address_space       = [for _, cidr in var.subnets : cidr]
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet" "v1" {
  address_prefixes                              = [each.value]
  resource_group_name                           = azurerm_virtual_network.v1.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.v1.name
  service_endpoints                             = var.service_endpoints
  for_each                                      = var.subnets
  name                                          = each.key
  private_link_service_network_policies_enabled = true

  dynamic "delegation" {
    for_each = toset(lookup(var.subnet_delegations, each.key, []))
    content {
      name = delegation.key
      service_delegation {
        name = delegation.key
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/action",
        ]
      }
    }
  }
}

resource "azurerm_network_security_group" "v1" {
  count               = length(keys(var.security_rules)) > 0 ? 1 : 0
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      priority                   = 100 * (index(keys(var.security_rules), security_rule.key) + 1)
      destination_address_prefix = coalesce(security_rule.value.destination_address_prefix,"*")
      source_address_prefix      = coalesce(security_rule.value.source_address_prefix,"*")
      destination_port_range     = security_rule.value.destination_port_range
      access                     = security_rule.value.access
      name                       = security_rule.key
      direction                  = "Inbound"
      protocol                   = "*"
      source_port_range          = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "v1" {
  for_each                  = length(keys(var.security_rules)) > 0 ? var.subnets : {}
  network_security_group_id = azurerm_network_security_group.v1.0.id
  subnet_id                 = azurerm_subnet.v1[each.key].id
}

resource "azapi_resource" "private_dns_zone_link" {
  type      = "Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01"
  name      = azurerm_virtual_network.v1.name
  for_each  = toset(var.private_dns_zones)
  parent_id = each.key
  location  = "global"
  body = jsonencode({
    properties = {
      registrationEnabled = false
      virtualNetwork = {
        id = azurerm_virtual_network.v1.id
      }
    }
  })
}
