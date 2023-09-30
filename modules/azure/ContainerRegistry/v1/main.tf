
resource "azurerm_container_registry" "v1" {
  resource_group_name    = var.resource_group_name
  location               = var.location
  tags                   = var.tags
  name                   = var.name
  sku                    = var.sku
  admin_enabled          = false
  anonymous_pull_enabled = false
  retention_policy = [
    {
      enabled = false
      days    = 0
    }
  ]
}