resource "azurerm_mssql_database" "v1" {
  for_each                    = var.databases
  elastic_pool_id             = each.value.pool != null ? azurerm_mssql_elasticpool.v1[each.value.pool].id : null
  sku_name                    = each.value.pool == null ? each.value.sku : "ElasticPool"
  max_size_gb                 = each.value.pool == null ? each.value.size : null
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  tags                        = azurerm_mssql_server.v1[each.value.server].tags
  server_id                   = azurerm_mssql_server.v1[each.value.server].id
  name                        = each.key
  read_scale                  = false
  geo_backup_enabled          = true

  depends_on = [ 
    azurerm_mssql_elasticpool.v1
  ]

  lifecycle {
    prevent_destroy = true
  }
}
