resource "azurerm_private_dns_zone" "v1" {
  resource_group_name = var.resource_group_name
  tags                = var.tags
  name                = var.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "v1" {
  resource_group_name   = azurerm_private_dns_zone.v1.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.v1.name
  for_each              = toset(var.virtual_network_ids)
  name                  = regex(".*/(.*)$", each.key)[0]
  virtual_network_id    = each.key
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "v1" {
  for_each            = { for r in var.dns_a_records : r.name => r }
  zone_name           = azurerm_private_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  records             = each.value.records
  name                = each.value.name
  ttl                 = each.value.ttl
}


resource "azurerm_private_dns_cname_record" "v1" {
  for_each            = { for r in var.dns_cname_records : r.name => r }
  zone_name           = azurerm_private_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  record              = each.value.record
  name                = each.value.name
  ttl                 = each.value.ttl
}
