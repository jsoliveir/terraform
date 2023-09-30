
locals {
  resource_group_name = regex(
    "resourceGroups/(.*)",
    var.resource_group_id
  )[0]
}


locals {
  node_pools = {
    for name, pool in var.node_pools : name => {
      type                = "VirtualMachineScaleSets"
      orchestratorVersion = var.kubernetes_version
      osDiskSizeGB        = pool.disk_size
      vnetSubnetID        = var.subnet_id
      enableAutoScaling   = false
      count               = pool.max_nodes
      vmSize              = pool.vm_size
      scaleDownMode       = "Delete"
      kubeletDiskType     = "OS"
      osDiskType          = "Managed"
      availabilityZones = [
        "2",
        "3",
        "1"
      ]
      nodeTaints             = pool.taints
      mode                   = pool.mode
      tags                   = var.tags
      osSKU                  = "Ubuntu"
      osType                 = "Linux"
      enableEncryptionAtHost = false
      enableNodePublicIP     = false
      enableUltraSSD         = false
      enableFIPS             = false
      maxPods                = 110
    }
  }
}

locals {
  system_node_pool = [
    for name, pool in local.node_pools : merge(pool, {
      name = name
    })
    if pool.mode == "System"
  ][0]
}

resource "null_resource" "cluster" {
  triggers = {
    cluster = jsonencode({
      version        = var.kubernetes_version
      resource_group = var.resource_group_id
      subnet         = var.subnet_id
      location       = var.location
      name           = var.name
    })
  }
}

resource "azapi_resource" "managed_cluster" {
  type                      = "Microsoft.ContainerService/managedClusters@2023-01-01"
  parent_id                 = var.resource_group_id
  location                  = var.location
  name                      = var.name
  tags                      = var.tags
  schema_validation_enabled = false
  ignore_missing_property   = true
  response_export_values    = ["*"]

  identity {
    type = "SystemAssigned"
  }
  body = jsonencode({
    properties = {
      kubernetesVersion   = var.kubernetes_version
      publicNetworkAccess = "Disabled"
      nodeResourceGroup   = var.name
      dnsPrefix           = replace(replace(var.name, local.resource_group_name, ""), "/\\W/", "")
      addonProfiles = {
        omsagent = {
          enabled = false
        }
      }
      apiServerAccessProfile = {
        enablePrivateClusterPublicFQDN = true
        enablePrivateCluster           = true
        privateDNSZone                 = "None"
      }
      autoUpgradeProfile = {
        upgradeChannel = "none"
      }
      servicePrincipalProfile = {
        clientId = "msi"
      }
      agentPoolProfiles = [
        local.system_node_pool
      ]
      aadProfile = {
        managed = true
      }
      enableRBAC = true

      autoScalerProfile = {
        "expander"                         = "random"
        "scale-down-utilization-threshold" = "0.5"
        "skip-nodes-with-local-storage"    = "false"
        "balance-similar-node-groups"      = "false"
        "scale-down-delay-after-failure"   = "3m"
        "scale-down-delay-after-delete"    = "10s"
        "max-graceful-termination-sec"     = "600"
        "skip-nodes-with-system-pods"      = "true"
        "max-total-unready-percentage"     = "45"
        "scale-down-delay-after-add"       = "10m"
        "scale-down-unneeded-time"         = "10m"
        "max-node-provision-time"          = "15m"
        "scale-down-unready-time"          = "20m"
        "new-pod-scale-up-delay"           = "0s"
        "max-empty-bulk-delete"            = "10"
        "ok-total-unready-count"           = "3"
        "scan-interval"                    = "10s"
      }
      networkProfile = {
        networkPlugin = "kubenet"
      }
      storageProfile = {
        diskCSIDriver = {
          enabled = true
        }
        fileCSIDriver = {
          enabled = true
        }
        snapshotController = {
          enabled = false
        }
      }
    }
  })
  lifecycle {
    ignore_changes = [
      body
    ]
    # replace_triggered_by = [
    #   null_resource.cluster
    # ]
  }
}



resource "azapi_update_resource" "managed_cluster_pool" {
  type      = "Microsoft.ContainerService/managedClusters/agentPools@2023-01-01"
  parent_id = azapi_resource.managed_cluster.id
  body      = jsonencode({ properties = local.system_node_pool })
  name      = local.system_node_pool.name
}

resource "azapi_resource" "managed_cluster_pool" {
  type      = "Microsoft.ContainerService/managedClusters/agentPools@2023-01-01"
  parent_id = azapi_resource.managed_cluster.id
  body      = jsonencode({ properties = each.value })
  name      = each.key
  for_each = {
    for name, pool in local.node_pools : name => pool
    if name != local.system_node_pool.name
  }
}
