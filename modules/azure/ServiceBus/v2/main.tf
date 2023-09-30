
resource "azapi_resource" "service_bus" {
  type      = "Microsoft.ServiceBus/namespaces@2022-10-01-preview"
  parent_id = var.resource_group_id
  name      = var.name
  location  = var.location
  tags      = var.tags
  body = jsonencode({
    sku = {
      capacity = var.capacity
      tier     = var.tier
      name     = var.sku
    }
    properties = {
      publicNetworkAccess = (var.tier == "Premium" ? "Disabled" : "Enabled")
      minimumTlsVersion   = "1.2"
      disableLocalAuth    = false
      zoneRedundant       = false
    }
  })
}

resource "azapi_resource" "service_bus_root_key" {
  type      = "Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview"
  parent_id = azapi_resource.service_bus.id
  name      = "RootSharedAccessKey"
  body = jsonencode({
    properties = {
      rights = ["Listen", "Manage", "Send"]
    }
  })
}

resource "azapi_resource" "service_bus_queues" {
  type      = "Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview"
  parent_id = azapi_resource.service_bus.id
  for_each  = toset(var.queues)
  name      = each.key
  body = jsonencode({
    properties = {
      autoDeleteOnIdle                    = "P10675199DT2H48M5.4775807S"
      defaultMessageTimeToLive            = "P10675199DT2H48M5.4775807S"
      duplicateDetectionHistoryTimeWindow = "PT10M"
      lockDuration                        = "PT1M"
      requiresDuplicateDetection          = false
      enablePartitioning                  = false
      deadLetteringOnMessageExpiration    = true
      maxMessageSizeInKilobytes           = 256
      maxSizeInMegabytes                  = 5120
    }
  })
}

resource "azapi_resource" "service_bus_queue_authorization_rules" {
  type      = "Microsoft.ServiceBus/namespaces/queues/authorizationrules@2022-01-01-preview"
  parent_id = azapi_resource.service_bus_queues[each.key].id
  for_each  = toset(var.queues)
  name      = each.key
  body = jsonencode({
    properties = {
      rights = ["Listen", "Send", "Manage"]
    }
  })
}

resource "azapi_resource" "service_bus_network_rules" {
  type      = "Microsoft.ServiceBus/namespaces/networkRuleSets@2022-01-01-preview"
  count     = var.tier == "Premium" ? 1 : 0
  parent_id = azapi_resource.service_bus.id
  name      = "default"
  body = jsonencode({
    properties = {
      publicNetworkAccess = "Enabled"
      defaultAction       = "Allow"
      virtualNetworkRules = []
      ipRules             = []
    }
  })
}

module "private_endpoints" {
  private_dns_zone         = "privatelink.servicebus.windows.net"
  count                    = var.tier == "Premium" ? 1 : 0
  location                 = azapi_resource.service_bus.location
  source                   = "../../PrivateEndpoint/v1"
  name                     = azapi_resource.service_bus.name
  private_link_resource_id = azapi_resource.service_bus.id
  resource_group_id        = var.resource_group_id
  subnet_id                = var.subnet_id
  private_link_group_id    = "namespace"
  tags                     = var.tags
}


