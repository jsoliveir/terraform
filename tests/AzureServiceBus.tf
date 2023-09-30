module "servicebus" {
  for_each            = local.config.azure.servicebus
  private_dns_zone_id = data.azurerm_private_dns_zone.plink["privatelink.servicebus.windows.net"].id
  subnet_id           = module.network[each.value.network].subnets[each.value.subnet].id
  location            = module.network[each.value.network].location
  source              = "../../../../modules/terraform/azure/ServiceBus/v1"
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  sku                 = each.value.sku
  name                = each.key
  queues = {
    for name in each.value.queues : name => {
      default_message_ttl                  = "P10675199DT2H48M5.4775807S"
      max_size_in_megabytes                = 5120
      dead_lettering_on_message_expiration = true
      max_delivery_count                   = 10
    }
  }
}