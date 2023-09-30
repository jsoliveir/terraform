output "primary_connection_string"  {
    value = "${azurerm_signalr_service.v1.primary_connection_string}ClientEndpoint=${var.entrypoint};"
}

output "name"  {
    value = azurerm_signalr_service.v1.name
}