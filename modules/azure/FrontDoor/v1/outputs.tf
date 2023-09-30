output "id" {
  value = azurerm_cdn_frontdoor_profile.v1.id
}

output "endpoints" {
  value = azurerm_cdn_frontdoor_endpoint.v1
}

output "domains" {
  value = azurerm_cdn_frontdoor_custom_domain.v1
}
