data "azurerm_client_config" "current" {}

resource "azapi_resource" "keyvault" {
  type      = "Microsoft.KeyVault/vaults@2022-11-01"
  parent_id = var.resource_group_id
  name      = var.name
  location  = var.location
  body = jsonencode({
    properties = {
      tenantId                  = data.azurerm_client_config.current.tenant_id
      softDeleteRetentionInDays = var.retention_days
      enableSoftDelete          = true
      enableRbacAuthorization   = true
      sku = {
        name   = "standard"
        family = "A"
      }
    }
  })
  lifecycle {
    prevent_destroy = false
  }
}


resource "azapi_resource" "keyvault_secret" {
  type      = "Microsoft.KeyVault/vaults/secrets@2022-11-01"
  parent_id = azapi_resource.keyvault.id
  for_each  = var.secrets
  name      = each.key
  body = jsonencode({
    properties = {
      value = each.value
    }
  })
}
