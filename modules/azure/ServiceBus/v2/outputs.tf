data "azapi_resource_action" "service_bus_root_key" {
  type                   = "Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview"
  resource_id            = azapi_resource.service_bus_root_key.id
  action                 = "listKeys"
  response_export_values = ["*"]
}

output "id" {
  value = azapi_resource.service_bus.id
}

output "name" {
  value = azapi_resource.service_bus.name
}

output "primary_connection_string" {
  value = jsondecode(data.azapi_resource_action.service_bus_root_key.output).primaryConnectionString
}
