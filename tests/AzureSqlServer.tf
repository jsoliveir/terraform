
module "mssql" {
  private_dns_zone_id = data.azurerm_private_dns_zone.plink["privatelink.database.windows.net"].id
  source              = "../../../../modules/terraform/azure/SqlServer/v1"
  aad_admin_group     = local.config.azure.mssql.adminGroup
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags

  servers = {
    for name, server in local.config.azure.mssql.servers :
    name => {
      location : module.network[server.network].location
      subnet_id : module.network[server.network].subnets[server.subnet].id
      private : true
    }
  }

  database_pools = {
    for name, pool in local.config.azure.mssql.databasePools : name => {
      sku                      = pool.sku
      tier                     = pool.tier
      capacity                 = pool.capacity
      per_database_max_capcity = pool.maxCapacityPerDatabase
      per_database_min_capcity = pool.minCapacityPerDatabase
      max_size_gb              = pool.maxDatabaseSize
      server                   = pool.server
    }
  }

  databases = {
    for name, db in local.config.azure.mssql.databases : name => {
      server = db.server
      pool   = contains(keys(db), "pool") ? db.pool : null
      size   = contains(keys(db), "size") ? db.size : null
      sku    = contains(keys(db), "sku") ? db.sku : null
    }
  }
}
