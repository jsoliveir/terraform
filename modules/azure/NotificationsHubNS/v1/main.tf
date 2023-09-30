resource "azurerm_notification_hub_namespace" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  namespace_type      = "NotificationHub"
  location            = var.location
  tags                = var.tags
  sku_name            = var.sku
}

resource "azurerm_notification_hub" "v1" {
  for_each            = toset(var.hubs)
  resource_group_name = azurerm_notification_hub_namespace.v1.resource_group_name
  location            = azurerm_notification_hub_namespace.v1.location
  namespace_name      = azurerm_notification_hub_namespace.v1.name
  name                = each.key
}

module "private_endpoint" {
  count                    = var.create_private_endpoint ? 1 : 0
  location                 = azurerm_notification_hub_namespace.v1.location
  private_link_resource_id = azurerm_notification_hub_namespace.v1.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.subnet_id
  private_link_group       = "namespace"
  tags                     = var.tags
}