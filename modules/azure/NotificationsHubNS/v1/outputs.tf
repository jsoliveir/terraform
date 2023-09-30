data "azapi_resource_action" "shared_root_key" {
  type                   = "Microsoft.NotificationHubs/namespaces/AuthorizationRules@2017-04-01"
  resource_id            = "${azurerm_notification_hub_namespace.v1.id}/authorizationRules/RootManageSharedAccessKey"
  action                 = "listKeys"
  response_export_values = ["*"]
}

output "primary_connection_string" {
  value = join(";", [
    "Endpoint=sb://${azurerm_notification_hub_namespace.v1.servicebus_endpoint}",
    "SharedAccessKeyName=RootManageSharedAccessKey",
    "SharedAccessKey=${jsondecode(data.azapi_resource_action.shared_root_key.output).primaryKey}"
  ])
}

output "name" {
  value = azurerm_notification_hub_namespace.v1.name
}
