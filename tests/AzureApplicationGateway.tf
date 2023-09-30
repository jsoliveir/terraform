
module "gateway" {
  for_each            = local.config.azure.gateways
  source              = "../../../../modules/terraform/azure/ApplicationGateway/v1"
  private_ip_address  = lower(each.value.private_ip) != "none" ? each.value.private_ip : null
  subnet_id           = module.network[each.value.network].subnets[each.value.subnet].id
  location            = module.network[each.value.network].location
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  firewall_mode       = each.value.firewallMode
  capacity            = each.value.capacity
  tier                = each.value.tier
  sku                 = each.value.sku
  name                = each.key
  certificates = {
    for domain, value in each.value.certificates:
    domain => module.keyvault.secrets[value.secret]
  }
  listeners = {
    for domain, properties in each.value.listeners : domain => {
      backend_host     = contains(keys(properties), "backendHost") ? properties.backendHost : null
      backend_protocol = properties.backendProtocol
      backend_pool     = properties.backendPool
      certificate      = properties.certificate
      public           = properties.public
    }
  }
}
