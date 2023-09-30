resource "azurerm_redis_cache" "v1" {
  name                          = "${var.resource_group_name}-${var.name}"
  resource_group_name           = var.resource_group_name
  enable_non_ssl_port           = var.enable_non_ssl_port
  location                      = var.location
  capacity                      = var.capacity
  family                        = var.family
  tags                          = var.tags
  sku_name                      = var.sku
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"

  lifecycle {
    ignore_changes = [
      tenant_settings
    ]
    prevent_destroy = true
  }
}

module "private_endpoint" {
  location                 = azurerm_redis_cache.v1.location
  private_link_resource_id = azurerm_redis_cache.v1.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.subnet_id
  private_link_group       = "redisCache"
  tags                     = var.tags
}


resource "azurerm_redis_firewall_rule" "v1" {
  for_each            = toset(var.allow_network_cidrs)
  resource_group_name = azurerm_redis_cache.v1.resource_group_name
  name                = replace(each.key, "/\\W/", "_")
  redis_cache_name    = azurerm_redis_cache.v1.name
  end_ip              = cidrhost(each.value, -1)
  start_ip            = cidrhost(each.value, 1)
}

