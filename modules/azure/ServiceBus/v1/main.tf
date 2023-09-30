resource "azurerm_servicebus_namespace" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  sku                 = title(var.sku)
  location            = var.location
  tags                = var.tags
  zone_redundant      = false
  local_auth_enabled  = true
  capacity            = 0
}


module "private_endpoint" {
  count                    = title(var.sku) == "Premium" ? 1 : 0
  location                 = azurerm_servicebus_namespace.v1.location
  private_link_resource_id = azurerm_servicebus_namespace.v1.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.subnet_id
  tags                     = var.tags
  private_link_group       = "namespace"
}

resource "azurerm_servicebus_queue" "v1" {
  for_each                                = var.queues
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  namespace_id                            = azurerm_servicebus_namespace.v1.id
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  auto_delete_on_idle                     = each.value.default_message_ttl
  default_message_ttl                     = each.value.default_message_ttl
  max_delivery_count                      = each.value.max_delivery_count
  name                                    = each.key
  duplicate_detection_history_time_window = "PT10M"
  lock_duration                           = "PT1M"
  requires_duplicate_detection            = false
  enable_batched_operations               = true
  enable_partitioning                     = false
  requires_session                        = false
}

resource "azurerm_servicebus_namespace_authorization_rule" "v1" {
  namespace_id = azurerm_servicebus_namespace.v1.id
  name         = "RootKey"
  listen       = true
  manage       = true
  send         = true
}

resource "azurerm_servicebus_queue_authorization_rule" "v1" {
  for_each = var.queues
  queue_id = azurerm_servicebus_queue.v1[each.key].id
  name     = each.key
  listen   = true
  manage   = true
  send     = true
}
