resource "azurerm_container_group" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  subnet_ids          = var.private ? [var.subnet_id] : null
  ip_address_type     = var.private ? "Private" : "Public"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  os_type             = "Linux"

  identity {
    type = "SystemAssigned"
  }

  dynamic "image_registry_credential" {
    for_each = { for acr in var.acr_credentials : acr.server => acr }
    content {
      username = image_registry_credential.value.username
      password = image_registry_credential.value.password
      server   = image_registry_credential.key
    }
  }
  exposed_port = [
    for port in var.ports : {
      protocol = upper(port.protocol)
      port     = port.port
  }]
  dns_name_label = (
    var.private == false
    ? "${var.resource_group_name}-${var.name}"
    : null
  )
  container {
    name                         = "${var.resource_group_name}-${var.name}"
    memory                       = tostring(var.memory)
    cpu                          = tostring(var.cpu)
    image                        = lower(var.image)
    environment_variables        = var.variables
    secure_environment_variables = var.secrets
    dynamic "ports" {
      for_each = { for port in var.ports : port.port => port }
      content {
        protocol = upper(ports.value.protocol)
        port     = ports.key
      }
    }
    dynamic "volume" {
      for_each = { for v in var.volumes : v.share_name => v }
      content {
        storage_account_name = volume.value.storage_account_name
        storage_account_key  = volume.value.storage_account_key
        mount_path           = volume.value.mount_path
        share_name           = volume.value.share_name
        name                 = volume.key
      }
    }
  }
}
