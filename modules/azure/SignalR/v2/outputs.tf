data "azapi_resource_action" "signalr_connection_string" {
  type                   = "Microsoft.SignalRService/SignalR@2022-02-01"
  resource_id            = azapi_resource.signalr.id
  action                 = "listKeys"
  response_export_values = ["*"]
}

output "id" {
  value = azapi_resource.signalr.id
}

output "name" {
  value = azapi_resource.signalr.name
}

output "primary_connection_string" {
  value = "${jsondecode(data.azapi_resource_action.signalr_connection_string.output).primaryConnectionString}ClientEndpoint=${var.client_endpoint};"
}
