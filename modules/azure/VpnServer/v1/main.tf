resource "random_password" "admin_password" {
  override_special = "!#$%&*()-_=+[]{}<>:?"
  special          = true
  length           = 16
}

resource "azurerm_public_ip" "v1" {
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
    public_ip_address_id          = azurerm_public_ip.v1.id
    subnet_id                     = var.subnet_id
    name                          = "default"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "v1" {
  name                = "${var.resource_group_name}-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  security_rule {
    name                       = "OpenVpn"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "1194"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "v1" {
  network_security_group_id = azurerm_network_security_group.v1.id
  network_interface_id      = azurerm_network_interface.v1.id
}

resource "azurerm_virtual_machine" "v1" {
  name                          = "${var.resource_group_name}-${var.name}"
  network_interface_ids         = [azurerm_network_interface.v1.id]
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tags                          = var.tags
  vm_size                       = "Standard_B2s"
  delete_os_disk_on_termination = true

  storage_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.resource_group_name}-${var.name}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = 50
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "vpnadmin"
    admin_password = random_password.admin_password.result
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    password = random_password.admin_password.result
    host     = azurerm_public_ip.v1.ip_address
    user     = "vpnadmin"
    type     = "ssh"
    port     = "22"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/pwsh.sh"
    destination = "/tmp/pwsh.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/mongodb.sh"
    destination = "/tmp/mongodb.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/pritunl.sh"
    destination = "/tmp/pritunl.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/*.sh",
      "/tmp/pwsh.sh",
      "/tmp/mongodb.sh",
      "/tmp/pritunl.sh",
    ]
  }

}
