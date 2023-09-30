
resource "azurerm_dns_zone" "v1" {
  resource_group_name = var.resource_group_name
  name                = var.name
  tags                = var.tags
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_dns_a_record" "v1" {
  for_each            = { for r in var.dns_a_records : r.name => r }
  zone_name           = azurerm_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  name                = each.value.name
  records             = each.value.records
  ttl                 = each.value.ttl
}

resource "azurerm_dns_cname_record" "v1" {
  for_each            = { for r in var.dns_cname_records : r.name => r }
  zone_name           = azurerm_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  name                = each.value.name
  record              = each.value.record
  ttl                 = each.value.ttl
}

resource "azurerm_dns_mx_record" "v1" {
  for_each            = { for r in var.dns_mx_records : r.name => r }
  zone_name           = azurerm_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl

  dynamic "record" {
    for_each = toset(each.value.records)
    content {
      exchange   = record.value
      preference = 10 * index(each.value.records,record.key) 
    }
  }
}

resource "azurerm_dns_txt_record" "v1" {
  for_each            = { for r in var.dns_txt_records : r.name => r }
  zone_name           = azurerm_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  name                = each.value.name
  ttl                 = each.value.ttl

  dynamic "record" {
    for_each = toset(each.value.records)
    content {
      value = record.value
    }
  }
}

resource "azurerm_dns_ns_record" "v1" {
  for_each            = { for r in var.dns_ns_records : r.name => r }
  zone_name           = azurerm_dns_zone.v1.name
  resource_group_name = var.resource_group_name
  records             = each.value.records
  name                = each.value.name
  ttl                 = each.value.ttl
}
