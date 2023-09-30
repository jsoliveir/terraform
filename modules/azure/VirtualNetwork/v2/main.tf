
resource "azapi_resource" "virtual_network" {
  type      = "Microsoft.Network/virtualNetworks@2022-09-01"
  parent_id = var.resource_group_id
  location  = var.location
  name      = var.name
  body = jsonencode({
    properties = {
      addressSpace = {
        addressPrefixes = [for _, subnet in var.subnets : subnet]
      }
    }
  })
}


resource "azapi_resource" "subnets" {
  for_each  = var.subnets
  type      = "Microsoft.Network/virtualNetworks/subnets@2022-09-01"
  parent_id = azapi_resource.virtual_network.id
  locks     = [azapi_resource.virtual_network.id]
  name      = each.key
  body = jsonencode({
    properties = {
      addressPrefixes = [each.value]
      delegations = [
        for subnet, delegation in var.subnet_delegations : {
          name = subnet
          properties = {
            serviceName = delegation
          }
        }
      ]
    }
  })
}
