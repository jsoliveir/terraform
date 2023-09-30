
data "azurerm_resources" "databases" {
  type = "Microsoft.Sql/servers/databases"
}

locals {
  databases = [
    for db in data.azurerm_resources.databases.resources : db
    if length(regexall(var.primary_server_id, db.id)) > 0
    && length(regexall("/databases/master",db.id)) == 0
  ]
}

resource "azurerm_mssql_failover_group" "failover" {
  databases = [for db in local.databases : db.id]
  name      = "${var.resource_group_name}-sql"
  server_id = var.primary_server_id

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  dynamic "partner_server" {
    for_each = toset(var.replicas_ids)
    content {
      id = partner_server.value
    }
  }
}
