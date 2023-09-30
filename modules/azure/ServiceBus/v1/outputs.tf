output "primary_connection_string"  {
    value = azurerm_servicebus_namespace.v1.default_primary_connection_string
}

output "name"  {
    value = azurerm_servicebus_namespace.v1.name
}