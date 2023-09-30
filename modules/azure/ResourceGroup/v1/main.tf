resource "azurerm_resource_group" "v1" {
  location =  var.location
  tags     = var.tags
  name     = var.name
}
