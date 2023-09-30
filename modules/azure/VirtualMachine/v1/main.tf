resource "azurerm_public_ip" "v1" {
  count                   = var.public_ip ? 1 : 0
  resource_group_name     = var.resource_group_name
  location                = var.location
  tags                    = var.tags
  name                    = "${var.resource_group_name}-${var.name}"
  domain_name_label       = "${var.resource_group_name}-${var.name}"
  sku                     = "Standard"
  allocation_method       = "Static"
  idle_timeout_in_minutes = 4
}

resource "azurerm_network_interface" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.v1.0.id : null
    private_ip_address            = var.private_ip_address
    subnet_id                     = var.subnet_id
    name                          = "default"
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_virtual_machine" "v1" {
  name                          = "${var.resource_group_name}-${var.name}"
  network_interface_ids         = [azurerm_network_interface.v1.id]
  resource_group_name           = var.resource_group_name
  location                      = var.location
  vm_size                       = var.vm_size
  tags                          = var.tags
  delete_os_disk_on_termination = true

  plan {
    publisher = var.image.publisher
    product   = var.image.offer
    name      = var.image.sku
  }

  storage_image_reference {
    publisher = var.image.publisher
    version   = var.image.version
    offer     = var.image.offer
    sku       = var.image.sku
  }

  storage_os_disk {
    name              = "${var.resource_group_name}-${var.name}"
    managed_disk_type = var.os_disk_type
    disk_size_gb      = var.os_disk_size
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = var.host_name
    admin_username = var.admin_user
    admin_password = var.admin_pass
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}
