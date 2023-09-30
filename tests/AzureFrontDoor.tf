module "frontdoor" {
  for_each                = local.config.azure.frontDoors
  source                  = "../../../../modules/terraform/azure/FrontDoor/v1"
  resource_group_name     = module.resource_group.name
  tags                    = module.resource_group.tags
  endpoints               = each.value.endpoints
  rulesets                = each.value.rulesets
  origins                 = each.value.origins
  routes                  = each.value.routes
  name                    = each.key
}
