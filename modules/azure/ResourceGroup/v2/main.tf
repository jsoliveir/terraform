
resource "azapi_resource" "resource_group" {
  type      = "Microsoft.Resources/resourceGroups@2022-09-01"
  parent_id = "/subscriptions/${var.subscription_id}"
  location  = var.location
  name      = var.name
}