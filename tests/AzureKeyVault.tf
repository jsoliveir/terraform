module "keyvault" {
  source              = "../../../../modules/terraform/azure/KeyVault/v1"
  retention_days      = local.config.azure.keyvault.softDeleteRetentionInDays
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  name                = module.resource_group.name
  secrets = merge(
    { for _, redis in module.redis : "${redis.name}--host" => "${redis.hostname}:${redis.ssl_port}" },
    { for _, redis in module.redis : "${redis.name}--cstr" => redis.primary_connection_string },
    { for _, asb in module.servicebus : "${asb.name}--cstr" => asb.primary_connection_string },
    { for _, sigr in module.signalr : "${sigr.name}--cstr" => sigr.primary_connection_string },
    { for _, asa in module.storage : "${asa.name}--cstr" => asa.primary_connection_string },
    { for _, redis in module.redis : "${redis.name}--key" => redis.primary_access_key },
    { for _, asa in module.storage : "${asa.name}--key" => asa.primary_access_key },
    # { for _, sql in module.mssql : "${sql.name}--admin-user" => sql.admin_user },
    # { for _, sql in module.mssql : "${sql.name}--admin-pass" => sql.admin_pass },
  )
  copy_from = [ 
    for secret in local.config.azure.keyvault.copyFrom : {
      resource_group = secret.resourceGroup
      subscription  = secret.subscription
      keyvault      = secret.keyvault
      secret        = secret.secret
      name          = secret.secret
    }
  ]
}