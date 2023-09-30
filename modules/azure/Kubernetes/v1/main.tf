data "azurerm_subscription" "current" {}

locals {
  system_node_pool = [
    for name, pool in var.node_pools : merge(pool, { name = name })
    if lower(pool.mode) == "system"
  ][0]
}

resource "azurerm_kubernetes_cluster" "v1" {
  dns_prefix                          = replace(var.name, "/\\W/", "")
  name                                = "${var.resource_group_name}-${var.name}"
  node_resource_group                 = "${var.resource_group_name}-${var.name}"
  public_network_access_enabled       = var.public_network_access_enabled
  private_cluster_enabled             = var.private_cluster_enabled
  resource_group_name                 = var.resource_group_name
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  kubernetes_version                  = var.kubernetes_version
  location                            = var.location
  tags                                = var.tags
  sku_tier                            = var.sku
  private_dns_zone_id                 = "None"
  local_account_disabled              = false
  role_based_access_control_enabled   = true
  private_cluster_public_fqdn_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id              = data.azurerm_subscription.current.tenant_id
    azure_rbac_enabled     = true
    managed                = true
    admin_group_object_ids = []
  }

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    os_disk_size_gb      = local.system_node_pool.disk_size
    node_count           = local.system_node_pool.max_nodes
    vm_size              = local.system_node_pool.vm_size
    name                 = local.system_node_pool.name
    orchestrator_version = var.kubernetes_version
    zones                = ["1", "2", "3"]
    vnet_subnet_id       = var.subnet_id
    tags                 = var.tags
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    kubelet_disk_type    = "OS"
    fips_enabled         = false
    enable_auto_scaling  = false
    node_taints          = local.system_node_pool.taints
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  storage_profile {
    blob_driver_enabled         = var.storage.blob_driver_enabled
    disk_driver_enabled         = var.storage.disk_driver_enabled
    file_driver_enabled         = var.storage.file_driver_enabled
    snapshot_controller_enabled = var.storage.snapshot_controller_enabled
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "v1" {
  for_each              = { for name, pool in var.node_pools : name => pool if name != local.system_node_pool.name }
  kubernetes_cluster_id = azurerm_kubernetes_cluster.v1.id
  node_count            = each.value.max_nodes
  orchestrator_version  = var.kubernetes_version
  os_disk_size_gb       = each.value.disk_size
  vm_size               = each.value.vm_size
  node_taints           = each.value.taints
  zones                 = ["1", "2", "3"]
  vnet_subnet_id        = var.subnet_id
  tags                  = var.tags
  name                  = each.key
  os_disk_type          = "Managed"
  os_sku                = "Ubuntu"
  kubelet_disk_type     = "OS"
  fips_enabled          = false
  enable_auto_scaling   = false
}

resource "azurerm_role_assignment" "network_contributor" {
  principal_id         = azurerm_kubernetes_cluster.v1.identity[0].principal_id
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "key_vault_reader" {
  principal_id         = azurerm_kubernetes_cluster.v1.kubelet_identity[0].object_id
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Key Vault Reader"
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  principal_id         = azurerm_kubernetes_cluster.v1.kubelet_identity[0].object_id
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Key Vault Secrets User"
}

resource "azurerm_role_assignment" "kubernetes" {
  count =  var.azurerm_container_registry_id != null ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.v1.kubelet_identity[0].object_id
  scope                = var.azurerm_container_registry_id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "storage_account_contributor" {
  for_each = toset([
    "${var.resource_group_name}-${var.name}",
    "${var.resource_group_name}"
  ])
  principal_id         = azurerm_kubernetes_cluster.v1.kubelet_identity[0].object_id
  scope                = "${data.azurerm_subscription.current.id}/resourceGroups/${each.key}"
  role_definition_name = "Storage Account Contributor"
}
