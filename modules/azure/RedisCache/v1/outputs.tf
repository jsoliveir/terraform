output "primary_connection_string" {
  value = azurerm_redis_cache.v1.primary_connection_string
}

output "hostname" {
  value = azurerm_redis_cache.v1.hostname
}

output "primary_access_key" {
  value = azurerm_redis_cache.v1.primary_access_key
}

output "ssl_port" {
  value = azurerm_redis_cache.v1.ssl_port
}

output "port" {
  value = azurerm_redis_cache.v1.port
}

output "name"  {
    value = azurerm_redis_cache.v1.name
}