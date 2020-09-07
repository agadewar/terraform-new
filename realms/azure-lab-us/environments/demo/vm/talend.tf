resource "azurerm_network_security_group" "talend" {
  name                = "talend-${var.realm}-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-AllTraffic-Sapience-Dallas-Office"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_sapience_dallas_office
    destination_address_prefix = "*"
  } 

    security_rule {
    name                       = "Allow-AllTraffic-Sapience-Pune-Office"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_sapience_pune_office
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-8003-Open-To-The-World"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "8003"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-8004-Open-To-The-World"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "8004"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-8891-Open-To-The-World"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "8891"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_virtual_machine" "talend" {
  depends_on            = [azurerm_network_interface.talend, azurerm_managed_disk.talend]

  name                  = "talend-${var.realm}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.talend.id]
  vm_size               = "Standard_B2ms"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0002-com-ubuntu-minimal-xenial-daily"
    sku       = "minimal-16_04-daily-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "talend-os-${var.realm}-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "talend"
    admin_username = var.talend_admin_username
    admin_password = var.talend_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
            path     = "/home/talendadmin/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNsGPZfbYrIs1T6OFO3FKpR1vO6G9t288gjIi8SnxLCkugfk3HDmhMH9BU69h+E4sn7M9puTmPnLDOTgKeP3VZDFXqfiAxMS/h08DkwC7EB9Puu5v/mj4DLNnarL5zRUJ8HKdAwwBShUHOt1FJfGSy1n3MoobG9kHqaxAeO9fMbmU+0geuOatzQfnC/1wyzUV41mANFI2e1e7bmpr/fojAJDFWs4YJnDtLCkUo5UOf7HijGnoinXwzPjTiLSot7/buQ6MogctJwf+lalsGdrBTED2RIo4V/xuC7NU5tDrK7P1Qpv2xo3bwmdAJrPdBw95teazQeEmCWTMkIFeaFM8V"
        }
  }

  storage_data_disk {
    name            = "talend-data-${var.realm}-${var.environment}"
    managed_disk_id = azurerm_managed_disk.talend.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "talend" {
  name                 = "talend-data-${var.realm}-${var.environment}"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"

  tags = "${merge(
    local.common_tags
  )}"
  
  lifecycle{
    prevent_destroy = "true"
  }
}

resource "azurerm_public_ip" "talend" {
  name                         = "talend-${var.realm}-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "talend" {
  depends_on                = [azurerm_public_ip.talend, azurerm_network_security_group.talend]
  name                      = "talend-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.talend.id

  ip_configuration {
    name                          = "talend-${var.realm}-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network_env.outputs.env-application_subnet_id
    public_ip_address_id          = azurerm_public_ip.talend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_recovery_services_protected_vm" "talend" {
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = "${data.terraform_remote_state.backup.outputs.vault}"
  source_vm_id        = "${azurerm_virtual_machine.talend.id}"
  backup_policy_id    = "${data.terraform_remote_state.backup.outputs.id_daily_14}"
}

resource "azurerm_private_dns_a_record" "talend" {
  name                = "talend.${var.environment}"
  zone_name           = data.terraform_remote_state.dns_realm.outputs.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.talend.private_ip_address]
}