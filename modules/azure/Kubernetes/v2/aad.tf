
data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "NetworkContributor" {
  principal_id         = jsondecode(azapi_resource.managed_cluster.output).identity.principalId
  scope                = split("/subnets",var.subnet_id)[0]
  role_definition_name = "Network Contributor"
}

# resource "azurerm_role_assignment" "aad_AcrPull" {
#   principal_id         = azurerm_kubernetes_cluster.v1.kubelet_identity[0].object_id
#   scope                = var.container_registry_id
#   role_definition_name = "AcrPull"
# }

resource "azurerm_role_assignment" "KeyVaultReader" {
  principal_id         = jsondecode(azapi_resource.managed_cluster.output).properties.identityProfile.kubeletidentity.objectId
  scope                = var.resource_group_id
  role_definition_name = "Key Vault Reader"
}

resource "azurerm_role_assignment" "KeyVaultSecretsUser" {
  principal_id         = jsondecode(azapi_resource.managed_cluster.output).properties.identityProfile.kubeletidentity.objectId
  scope                = var.resource_group_id
  role_definition_name = "Key Vault Secrets User"
}

resource "azurerm_role_assignment" "StorageAccountContributor" {
  principal_id         = jsondecode(azapi_resource.managed_cluster.output).properties.identityProfile.kubeletidentity.objectId
  role_definition_name = "Storage Account Contributor"
  scope                = var.resource_group_id
}
