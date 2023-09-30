
resource "azapi_resource" "redis" {
  type                   = "Microsoft.Cache/redis@2022-06-01"
  parent_id              = var.resource_group_id
  name                   = var.name
  location               = var.location
  tags                   = var.tags
  response_export_values = ["*"]
  body = jsonencode({
    properties = {
      enableNonSslPort = var.enable_non_ssl_port
      sku = {
        capacity = var.capacity
        family   = var.family
        name     = var.sku
      }
      minimumTlsVersion   = "1.2"
      publicNetworkAccess = "Disabled"
    }
  })
}

module "private_endpoints" {
  private_dns_zone         = "privatelink.redis.cache.windows.net"
  location                 = azapi_resource.redis.location
  source                   = "../../PrivateEndpoint/v1"
  name                     = azapi_resource.redis.name
  private_link_resource_id = azapi_resource.redis.id
  resource_group_id        = var.resource_group_id
  subnet_id                = var.subnet_id
  private_link_group_id    = "redisCache"
  tags                     = var.tags
}
