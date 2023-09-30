output "kubeletIdentity" {
    value = jsondecode(azapi_resource.managed_cluster.output).properties.identityProfile.kubeletidentity.objectId
}

output "identity" {
    value = jsondecode(azapi_resource.managed_cluster.output).identity.principalId
}

output "id" {
  value = azapi_resource.managed_cluster.id
}

output "name" {
  value = azapi_resource.managed_cluster.name
}