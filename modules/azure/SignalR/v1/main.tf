
resource "azurerm_signalr_service" "v1" {
  name                      = "${var.resource_group_name}-${var.name}"
  resource_group_name       = var.resource_group_name
  location                  = var.location
  tags                      = var.tags
  service_mode              = "Default"
  messaging_logs_enabled    = true
  connectivity_logs_enabled = true

  live_trace {
    enabled                   = false
    connectivity_logs_enabled = true
    http_request_logs_enabled = true
    messaging_logs_enabled    = true
  }

  sku {
    capacity = var.capacity
    name     = var.sku
  }

  cors {
    allowed_origins = ["*"]
  }
}

module "private_endpoint" {
  location                 = azurerm_signalr_service.v1.location
  private_link_resource_id = azurerm_signalr_service.v1.id
  source                   = "../../PrivateEndpoint/v1"
  resource_group_name      = var.resource_group_name
  private_dns_zone_id      = var.private_dns_zone_id
  subnet_id                = var.subnet_id
  tags                     = var.tags
  private_link_group       = "signalr"
}


resource "azurerm_signalr_service_network_acl" "v1" {
  signalr_service_id  = azurerm_signalr_service.v1.id
  default_action     = "Deny"

  public_network {
    
  }
  private_endpoint {
    id                    = module.private_endpoint.id
    allowed_request_types = [
      "ServerConnection",
      "ClientConnection",
      "RESTAPI",
      "Trace"
    ]
  } 
}
