output "subnets" {
  value = azurerm_subnet.v1
}

output "network" {
  value =  azurerm_virtual_network.v1
}

output "location" {
  value =  azurerm_virtual_network.v1.location
}

output "name" {
  value = azurerm_virtual_network.v1.name
}

output "id" {
  value = azurerm_virtual_network.v1.id
}

