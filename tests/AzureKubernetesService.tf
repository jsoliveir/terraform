
module "kubernetes" {
  for_each            = local.config.azure.kubernetes
  subnet_id           = module.network[each.value.network].subnets[each.value.subnet].id
  source              = "../../../../modules/terraform/azure/Kubernetes/v1"
  location            = module.network[each.value.network].location
  resource_group_name = module.resource_group.name
  tags                = module.resource_group.tags
  kubernetes_version  = each.value.version
  name                = each.key
  node_pools = {
    for name, pool in each.value.nodePools : name => {
      vm_size   = pool.vmSize
      disk_size = pool.diskSize
      taints    = pool.taints
      max_nodes = pool.nodes
      mode      = pool.mode
    }
  }
}