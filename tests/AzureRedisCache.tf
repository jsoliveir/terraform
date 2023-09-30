module "redis" {
  for_each            = local.config.azure.redis
  source              = "../../../../modules/terraform/azure/RedisCache/v1"
  private_dns_zone_id = data.azurerm_private_dns_zone.plink["privatelink.redis.cache.windows.net"].id
  subnet_id           = module.network[each.value.network].subnets[each.value.subnet].id
  location            = module.network[each.value.network].location
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  capacity            = each.value.capacity
  family              = each.value.family
  sku                 = each.value.sku
  allow_network_cidrs = ["10.0.0.0/8"]
  name                = each.key
  enable_non_ssl_port = true
}