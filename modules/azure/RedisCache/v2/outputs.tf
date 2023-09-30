

data "azapi_resource_action" "redis_keys" {
  type                   = "Microsoft.Cache/redis@2022-06-01"
  resource_id            = azapi_resource.redis.id
  action                 = "listKeys"
  response_export_values = ["*"]
}

locals{
  redis = jsondecode(azapi_resource.redis.output)
}

output "id" {
  value = azapi_resource.redis.id
}

output "name" {
  value = azapi_resource.redis.name
}

output "primary_access_key" {
  value = jsondecode(data.azapi_resource_action.redis_keys.output).primaryKey
}

output "host" {
  value = "${local.redis.properties.hostName}:${local.redis.properties.sslPort}"
}


