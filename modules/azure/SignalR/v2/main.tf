
resource "azapi_resource" "signalr" {
  type      = "Microsoft.SignalRService/signalR@2022-08-01-preview"
  parent_id = var.resource_group_id
  name      = var.name
  location  = var.location
  tags      = var.tags
  body = jsonencode({
    kind = "SignalR"
    sku = {
      capacity = var.capacity
      tier     = var.tier
      name     = var.sku
    }
    
    properties = {
      publicNetworkAccess = "Disabled"
      disableLocalAuth    = false
      disableAadAuth      = false
      cors = {
        allowedOrigins = ["*"]
      }
    }
  })
}

module "private_endpoints" {
  private_dns_zone         = "privatelink.service.signalr.net"
  location                 = azapi_resource.signalr.location
  source                   = "../../PrivateEndpoint/v1"
  name                     = azapi_resource.signalr.name
  private_link_resource_id = azapi_resource.signalr.id
  resource_group_id        = var.resource_group_id
  subnet_id                = var.subnet_id
  private_link_group_id    = "signalr"
  tags                     = var.tags
}
