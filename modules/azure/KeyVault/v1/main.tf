data "azurerm_client_config" "current" {}

data "azurerm_key_vault_secret" "copy" {
  count         = length(var.copy_from)
  name          = var.copy_from[count.index].secret
  key_vault_id  = join("", [
    "/subscriptions/${var.copy_from[count.index].subscription}",
    "/resourceGroups/${var.copy_from[count.index].resource_group}",
    "/providers/Microsoft.KeyVault/vaults/${var.copy_from[count.index].keyvault}"
  ])
}

resource "azurerm_key_vault" "v1" {
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  resource_group_name         = var.resource_group_name
  soft_delete_retention_days  = var.retention_days
  location                    = var.location
  sku_name                    = "standard"
  tags                        = var.tags
  name                        = var.name
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
  enable_rbac_authorization   = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_secret" "copy" {
  count        = length(var.copy_from)
  content_type = data.azurerm_key_vault_secret.copy[count.index].content_type
  value        = data.azurerm_key_vault_secret.copy[count.index].value
  name         = var.copy_from[count.index].name
  key_vault_id = azurerm_key_vault.v1.id
}

resource "azurerm_key_vault_secret" "v1" {
  key_vault_id = azurerm_key_vault.v1.id
  for_each     = var.secrets
  value        = each.value
  name         = each.key
}

resource "azurerm_key_vault_certificate" "v1" {
  key_vault_id = azurerm_key_vault.v1.id
  for_each     = var.certificates
  name         = each.key
  certificate {
    password = each.value.password
    contents = each.value.data
  }
}

