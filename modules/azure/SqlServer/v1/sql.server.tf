resource "random_password" "v1" {
  count            = length(keys(var.servers)) > 0 ? 1 : 0
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_user_assigned_identity" "v1" {
  for_each            = var.servers
  name                = "${var.resource_group_name}-${each.key}"
  resource_group_name = var.resource_group_name
  location            = each.value.location
  tags                = var.tags
}

resource "azuread_directory_role" "readers" {
  count        = length(keys(var.servers)) > 0 ? 1 : 0
  display_name = "Directory Readers"
}

resource "azuread_directory_role_assignment" "readers" {
  for_each            = var.servers
  principal_object_id = azurerm_user_assigned_identity.v1[each.key].principal_id
  role_id             = azuread_directory_role.readers.0.template_id
}

data "azuread_group" "v1" {
  count        = length(keys(var.servers)) > 0 ? 1 : 0
  display_name = var.aad_admin_group
}

data "azurerm_subscription" "current" {}

resource "azurerm_mssql_server" "v1" {
  for_each                             = var.servers
  name                                 = "${var.resource_group_name}-${each.key}"
  primary_user_assigned_identity_id    = azurerm_user_assigned_identity.v1[each.key].id
  administrator_login                  = azurerm_user_assigned_identity.v1[each.key].principal_id
  administrator_login_password         = random_password.v1.0.result
  resource_group_name                  = var.resource_group_name
  public_network_access_enabled        = each.value.private == false
  outbound_network_restriction_enabled = each.value.subnet_id == null
  location                             = each.value.location
  tags                                 = var.tags
  version                              = "12.0"
  minimum_tls_version                  = "1.2"

  azuread_administrator {
    tenant_id                   = data.azurerm_subscription.current.tenant_id
    login_username              = data.azuread_group.v1.0.display_name
    object_id                   = data.azuread_group.v1.0.object_id
    azuread_authentication_only = false
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.v1[each.key].id
    ]
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      administrator_login
    ]
  }
}

module "private_endpoint" {
  for_each                 = { for name, server in var.servers : name => server if server.private }
  location                 = azurerm_mssql_server.v1[each.key].location
  private_link_resource_id = azurerm_mssql_server.v1[each.key].id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = each.value.subnet_id
  private_link_group       = "sqlServer"
  tags                     = var.tags
}
