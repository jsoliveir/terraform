resource "azurerm_public_ip" "v1" {
  count                   = var.public_ip ? 1 : 0
  resource_group_name     = var.resource_group_name
  location                = var.location
  tags                    = var.tags
  name                    = "${var.resource_group_name}-${var.name}"
  domain_name_label       = "${var.resource_group_name}-${var.name}"
  sku                     = var.lb_sku
  allocation_method       = "Static"
  idle_timeout_in_minutes = 4
}

resource "azurerm_lb" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.lb_sku

  dynamic "frontend_ip_configuration" {
    for_each = toset(var.public_ip ? ["public"] : [])
    content {
      name                 = frontend_ip_configuration.key
      public_ip_address_id = azurerm_public_ip.v1.0.id
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = toset(!var.public_ip ? ["private"] : [])
    content {
      name                          = frontend_ip_configuration.key
      private_ip_address            = var.private_ip_address
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Static"
    }
  }
}


resource "azurerm_lb_backend_address_pool" "v1" {
  name            = "${var.resource_group_name}-${var.name}"
  loadbalancer_id = azurerm_lb.v1.id
}

resource "azurerm_lb_rule" "v1" {
  for_each                       = var.ports
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.v1.id]
  frontend_ip_configuration_name = var.public_ip ? "public" : "private"
  protocol                       = title(lower(each.value))
  loadbalancer_id                = azurerm_lb.v1.id
  backend_port                   = each.key
  frontend_port                  = each.key
  name                           = each.key
}

resource "azurerm_linux_virtual_machine_scale_set" "v1" {
  zones                           = title(var.lb_sku) == "Basic" ? null : [1, 2, 3]
  name                            = "${var.resource_group_name}-${var.name}"
  single_placement_group          = title(var.lb_sku) == "Basic"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  sku                             = var.vm_size
  tags                            = var.tags
  admin_username                  = var.admin_user
  admin_password                  = var.admin_pass
  computer_name_prefix            = var.host_name
  instances                       = var.replicas
  disable_password_authentication = false

  plan {
    publisher = var.image.publisher
    product   = var.image.offer
    name      = var.image.sku
  }

  source_image_reference {
    publisher = var.image.publisher
    version   = var.image.version
    offer     = var.image.offer
    sku       = var.image.sku
  }

  os_disk {
    disk_size_gb         = var.os_disk_size
    storage_account_type = var.os_disk_type
    caching              = "ReadWrite"
  }

  network_interface {
    name                 = "${var.resource_group_name}-${var.name}"
    enable_ip_forwarding = true
    primary              = true

    ip_configuration {
      subnet_id = var.subnet_id
      name      = "private"
      primary   = true
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.v1.id
      ]
    }
  }
}

