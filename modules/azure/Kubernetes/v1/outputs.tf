output "name" {
  value = azurerm_kubernetes_cluster.v1.name
}

output "id" {
  value = azurerm_kubernetes_cluster.v1.id
}

output "identity_id" {
  value = azurerm_kubernetes_cluster.v1.identity[0].principal_id
}

output "kubelet_identity_id" {
  value = azurerm_kubernetes_cluster.v1.kubelet_identity[0].object_id
}

output "kube_config" {
  value = {
    client_key             = azurerm_kubernetes_cluster.v1.kube_config[0].client_key
    client_certificate     = azurerm_kubernetes_cluster.v1.kube_config[0].client_certificate
    cluster_ca_certificate = azurerm_kubernetes_cluster.v1.kube_config[0].cluster_ca_certificate
    username               = azurerm_kubernetes_cluster.v1.kube_config[0].username
    password               = azurerm_kubernetes_cluster.v1.kube_config[0].password
    host                   = azurerm_kubernetes_cluster.v1.kube_config[0].host
  }
}
