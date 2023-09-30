output "principal_id" {
  value = azurerm_container_group.v1.identity[0].principal_id
}