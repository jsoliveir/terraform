resource "azurerm_storage_account" "v1" {
  name                              = replace("${var.resource_group_name}-${var.name}", "/\\W/", "")
  infrastructure_encryption_enabled = var.double_encryption_enabled
  account_replication_type          = var.account_replication_type
  resource_group_name               = var.resource_group_name
  account_tier                      = var.account_tier
  access_tier                       = var.access_tier
  location                          = var.location
  is_hns_enabled                    = var.datalake
  account_kind                      = var.account_kind
  nfsv3_enabled                     = var.nfsv3
  tags                              = var.tags
  allow_nested_items_to_be_public   = !var.private
  shared_access_key_enabled         = true
  enable_https_traffic_only         = true

  dynamic "static_website" {
    for_each = toset(var.static_website ? ["yes"] : [])
    content {
      index_document     = "index.html"
      error_404_document = "404.html"
    }

  }
  # Enabled from selected virtual networks and IP addresses
  public_network_access_enabled = true
  dynamic "custom_domain" {
    for_each = toset(var.custom_domain != null ? [var.custom_domain] : [])
    content {
      name          = custom_domain.value
      use_subdomain = false
    }
  }

  network_rules {
    default_action = var.private ? "Deny" : "Allow"
    bypass         = ["AzureServices"]
    virtual_network_subnet_ids = var.private ? [
      for s in var.allowed_subnets : s
    ] : []
    ip_rules = length(var.allowed_ips) > 0 ? flatten([
      var.allowed_ips
    ]) : []
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "v1" {
  for_each              = toset(var.containers)
  storage_account_name  = azurerm_storage_account.v1.name
  container_access_type = "private"
  name                  = each.key
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_share" "v1" {
  for_each             = { for share in var.shares : share.name => share }
  storage_account_name = azurerm_storage_account.v1.name
  quota                = each.value.size
  name                 = each.key
  lifecycle {
    prevent_destroy = true
  }
}

module "private_endpoint_blob" {
  count                    = length(var.containers) > 0 && var.private ? 1 : 0
  location                 = azurerm_storage_account.v1.location
  private_link_resource_id = azurerm_storage_account.v1.id
  private_dns_zone_id      = var.private_dns_zone_blob_id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  subnet_id                = var.subnet_id
  tags                     = var.tags
  private_link_group       = "blob"
  suffix                   = "blob"
}

module "private_endpoint_file" {
  count                    = length(var.shares) > 0 && var.private ? 1 : 0
  location                 = azurerm_storage_account.v1.location
  private_link_resource_id = azurerm_storage_account.v1.id
  private_dns_zone_id      = var.private_dns_zone_file_id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  subnet_id                = var.subnet_id
  tags                     = var.tags
  private_link_group       = "file"
  suffix                   = "file"
}
