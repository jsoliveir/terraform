module "resource_group" {
  source   = "../../../../modules/terraform/azure/ResourceGroup/v1"
  name     = local.config.azure.resourceGroup
  location = "northeurope"
  tags     = local.tags
}