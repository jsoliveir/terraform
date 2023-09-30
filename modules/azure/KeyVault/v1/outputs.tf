output "key_vault_id" {
  value = azurerm_key_vault.v1.id
}

output "secrets" {
  value = merge(
    { for secret in azurerm_key_vault_secret.copy: secret.name => secret.value },
    { for _,secret in azurerm_key_vault_secret.v1: secret.name => secret.value }
  )
}