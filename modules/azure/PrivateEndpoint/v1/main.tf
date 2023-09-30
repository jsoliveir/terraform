locals {
  name = "${regex(".*/(.*)$", var.private_link_resource_id)[0]}${var.suffix}"
}
resource "azurerm_private_endpoint" "v1" {
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  location                      = var.location
  name                          = local.name
  custom_network_interface_name = local.name
  tags                          = var.tags

  private_service_connection {
    private_connection_resource_id = var.private_link_resource_id
    subresource_names              = [var.private_link_group]
    name                           = local.name
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = local.name
    private_dns_zone_ids = [
      var.private_dns_zone_id
    ]
  }
}
