module "storage" {
  for_each                 = local.config.azure.storageAccounts
  private_dns_zone_blob_id = data.azurerm_private_dns_zone.plink["privatelink.blob.core.windows.net"].id
  private_dns_zone_file_id = data.azurerm_private_dns_zone.plink["privatelink.file.core.windows.net"].id
  subnet_id                = module.network[each.value.network].subnets[each.value.subnet].id
  source                   = "../../../../modules/terraform/azure/StorageAccount/v1"
  location                 = module.network[each.value.network].location
  resource_group_name      = module.resource_group.name
  tags                     = module.resource_group.tags
  account_replication_type = each.value.replication
  containers               = each.value.containers
  shares                   = each.value.shares
  account_tier             = each.value.tier
  account_kind             = each.value.kind
  name                     = each.key
  access_tier              = "Hot"
  nfsv3                    = each.value.nfsv3
  datalake                 = each.value.asdl
  allowed_subnets          = [for _, snet in module.network[each.value.network].subnets : snet.id]
  allowed_ips              = [chomp(data.http.ip.response_body)]
  private                  = true
}