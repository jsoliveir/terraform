output "id" {
  value = azurerm_private_dns_zone.v1.id
}
output "name" {
  value = azurerm_private_dns_zone.v1.name
}

output "resource_group_name" {
  value = azurerm_private_dns_zone.v1.resource_group_name
}

output "dns_a_records" {
  value = azurerm_private_dns_a_record.v1
}

