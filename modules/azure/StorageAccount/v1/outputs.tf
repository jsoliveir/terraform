output "primary_connection_string" {
  value = azurerm_storage_account.v1.primary_connection_string
}

output "primary_access_key" {
  value = azurerm_storage_account.v1.primary_access_key
}

output "name" {
  value = azurerm_storage_account.v1.name
}
