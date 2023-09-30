resource "azurerm_service_plan" "v1" {
  name                       = "${var.resource_group_name}-${var.name}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  tags                       = var.tags
  sku_name                   = var.sku
  os_type                    = "Linux"
}

resource "azurerm_linux_web_app" "v1" {
  for_each            = var.sites
  name                = "${var.resource_group_name}-${each.key}"
  service_plan_id     = azurerm_service_plan.v1.id
  resource_group_name = var.resource_group_name
  https_only          = true
  app_settings = merge(
    !var.private ? {} : {
      WEBSITE_DNS_SERVER     = "168.63.129.16"
      WEBSITE_VNET_ROUTE_ALL = 1
    },
  each.value.app_settings)
  location                  = var.location
  tags                      = var.tags
  virtual_network_subnet_id = var.outbound_subnet_id
  site_config {
    always_on        = !contains(["F1", "D1", "Free"], var.sku)
    ftps_state       = each.value.ftp ? "AllAllowed" : "Disabled"
    app_command_line = each.value.startup_command
    http2_enabled    = true

    application_stack {
      docker_image     = each.value.docker_image != null ? split(":", each.value.docker_image)[0] : null
      docker_image_tag = each.value.docker_image != null ? split(":", each.value.docker_image)[1] : null
      dotnet_version   = each.value.dotnet_version
      php_version      = each.value.php_version
    }
  }
  dynamic "backup" {
    for_each = toset(each.value.backups == null ? [] : ["default"])
    content {
      name                = backup.key
      storage_account_url = each.value.backups.storage_account_url
      schedule {
        retention_period_days = each.value.backups.retention_days
        frequency_interval    = each.value.backups.interval
        frequency_unit        = "Hour"
      }
    }
  }

  dynamic "storage_account" {
    for_each = { for i, v in each.value.volumes : "${i}" => v }
    content {
      account_name = storage_account.value.storage_account_name
      access_key   = storage_account.value.storage_account_key
      mount_path   = storage_account.value.mount_path
      share_name   = storage_account.value.share_name
      type         = storage_account.value.type
      name         = storage_account.key
    }
  }
}

module "private_endpoint" {
  for_each                 = { for k, v in var.sites : k => v if var.private }
  location                 = azurerm_linux_web_app.v1[each.key].location
  private_link_resource_id = azurerm_linux_web_app.v1[each.key].id
  source                   = "../../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.inbound_subnet_id
  tags                     = var.tags
  private_link_group       = "sites"
}
