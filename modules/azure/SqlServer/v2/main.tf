data "azurerm_client_config" "current" {}

resource "random_password" "password" {
  length = 12
}

resource "azapi_resource" "sql_server" {
  type      = "Microsoft.Sql/servers@2022-08-01-preview"
  parent_id = var.resource_group_id
  location  = var.location
  name      = var.name
  tags      = var.tags
  body = jsonencode({
    properties = {
      publicNetworkAccess        = "Disabled"
      version                    = "12.0"
      minimalTlsVersion          = "1.2"
      administratorLoginPassword = random_password.password.result
      administratorLogin         = var.admin_group_id
      administrators = {
        tenantId                  = data.azurerm_client_config.current.tenant_id
        sid                       = var.admin_group_id
        administratorType         = "ActiveDirectory"
        login                     = var.admin_group
        principalType             = "Group"
        azureADOnlyAuthentication = false
      }
    }
  })
}

module "private_endpoints" {
  private_dns_zone         = "privatelink.database.windows.net"
  location                 = azapi_resource.sql_server.location
  name                     = azapi_resource.sql_server.name
  private_link_resource_id = azapi_resource.sql_server.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_id        = var.resource_group_id
  subnet_id                = var.subnet_id
  private_link_group_id    = "sqlServer"
  tags                     = var.tags
}
