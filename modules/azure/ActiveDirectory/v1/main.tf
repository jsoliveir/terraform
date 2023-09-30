data "azuread_group" "v1" {
  for_each = toset(distinct([
    for ra in var.group_role_assignments : ra.group
  ]))
  display_name = each.key
}

resource "azurerm_role_assignment" "group" {
  for_each             = { for ra in var.group_role_assignments : "${ra.role}::${ra.group}" => ra }
  principal_id         = data.azuread_group.v1[each.value.group].id
  scope                = each.value.resource_id
  role_definition_name = each.value.role
}

resource "azurerm_role_assignment" "object" {
  for_each             = { for ra in var.object_role_assignments : "${ra.role}::${ra.object_id}" => ra }
  scope                = each.value.resource_id
  principal_id         = each.value.object_id
  role_definition_name = each.value.role
}
