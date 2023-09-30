locals {
  role_assignments = flatten([
    for assignment in local.config.azure.aadRoleAssingments : [
      for role in assignment.roles : {
        resource_id = module.resource_group.id
        group       = assignment.group
        role        = role
      }
    ]
  ])
}

data "azuread_group" "v1" {
  for_each     = toset(distinct([for ra in local.role_assignments : ra.group]))
  display_name = each.key
}

resource "azurerm_role_assignment" "rbac" {
  for_each             = { for ra in local.role_assignments : "${ra.role}::${ra.group}" => ra }
  principal_id         = data.azuread_group.v1[each.value.group].id
  scope                = module.resource_group.id
  role_definition_name = each.value.role
}