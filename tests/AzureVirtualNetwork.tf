
module "network" {
  for_each            = local.config.azure.networks
  source              = "../../../../modules/terraform/azure/VirtualNetwork/v1"
  private_dns_zones   = values(data.azurerm_private_dns_zone.plink)[*].id
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  location            = each.value.location
  subnets             = each.value.subnets
  name                = each.key
  service_endpoints = [
    "Microsoft.ServiceBus",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Sql"
  ]
}