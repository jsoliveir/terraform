resource "azurerm_static_site" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  sku_size            = var.sku
  sku_tier            = var.sku
}

module "private_endpoint" {
  count                    = var.private_dns_zone_id != null ? 1 : 0
  location                 = azurerm_static_site.v1.location
  private_link_resource_id = azurerm_static_site.v1.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.subnet_id
  private_link_group       = "staticSites"
  tags                     = var.tags
}

resource "azapi_resource" "cname_record" {
  for_each = var.custom_domains
  type     = "Microsoft.Network/dnsZones/CNAME@2018-05-01"
  name     = split(".", each.key)[0]
  body = jsonencode({
    properties = {
      TTL = 3600
      CNAMERecord = {
        cname = azurerm_static_site.v1.default_host_name
      }
    }
  })
  parent_id = join("", [
    "/subscriptions/", each.value.dns_zone_subscription,
    "/resourceGroups/", each.value.dns_zone_resource_group,
    "/providers/", "Microsoft.Network", "/dnsZones/", replace(each.key, "/^(.*?)\\./", "")
  ])
}

resource "azurerm_static_site_custom_domain" "v1" {
  for_each        = var.custom_domains
  depends_on      = [azapi_resource.cname_record]
  static_site_id  = azurerm_static_site.v1.id
  validation_type = "cname-delegation"
  domain_name     = each.key
}
