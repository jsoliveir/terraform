resource "azurerm_mssql_elasticpool" "v1" {
  for_each            = var.database_pools
  max_size_gb         = each.value.max_size_gb
  server_name         = azurerm_mssql_server.v1[each.value.server].name
  resource_group_name = var.resource_group_name
  license_type = (
    each.value.tier == "GeneralPurpose"
    || each.value.tier == "BusinessCritical"
    ? "LicenseIncluded"
    : null
  )
  location = azurerm_mssql_server.v1[each.value.server].location
  name     = each.key

  sku {
    name     = each.value.sku
    tier     = each.value.tier
    capacity = each.value.capacity
  }

  per_database_settings {
    min_capacity = each.value.per_database_min_capcity
    max_capacity = each.value.per_database_max_capcity
  }

  lifecycle {
    ignore_changes = [
      license_type
    ]
  }
}

