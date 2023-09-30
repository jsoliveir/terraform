module "signalr" {
  for_each            = local.config.azure.signalr
  private_dns_zone_id = data.azurerm_private_dns_zone.plink["privatelink.service.signalr.net"].id
  subnet_id           = module.network[each.value.network].subnets[each.value.subnet].id
  source              = "../../../../modules/terraform/azure/SignalR/v1"
  location            = module.network[each.value.network].location
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  entrypoint          = each.value.entrypoint
  capacity            = each.value.capacity
  sku                 = each.value.sku
  name                = each.key
}