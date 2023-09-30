data "azurerm_subscription" "current" {}

resource "azurerm_mysql_flexible_server" "v1" {
  name                         = "${var.resource_group_name}-${var.name}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  tags                         = var.tags
  administrator_login          = var.admin_username
  administrator_password       = var.admin_password
  sku_name                     = var.sku
  version                      = var.platform_version
  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = false
  zone                         = "1"
  storage {
    size_gb           = var.storage_size
    auto_grow_enabled = var.auto_grow_enabled
  }
  maintenance_window {
    start_hour = 20
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "allow" {
  for_each            = var.firewall_rules
  server_name         = azurerm_mysql_flexible_server.v1.name
  resource_group_name = var.resource_group_name
  start_ip_address    = each.value.start
  end_ip_address      = each.value.end
  name                = each.key
}

resource "azurerm_mysql_flexible_database" "v1" {
  for_each            = toset(var.databases)
  resource_group_name = azurerm_mysql_flexible_server.v1.resource_group_name
  server_name         = azurerm_mysql_flexible_server.v1.name
  collation           = "latin1_swedish_ci"
  charset             = "latin1"
  name                = each.key
  lifecycle {
    prevent_destroy = true
  }
}


module "private_endpoint" {
  count                    = var.subnet_id != null ? 1 : 0
  location                 = azurerm_mysql_flexible_server.v1.location
  private_link_resource_id = azurerm_mysql_flexible_server.v1.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.subnet_id
  private_link_group       = "mysqlServer"
  tags                     = var.tags
}
