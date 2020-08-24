resource "azurerm_network_security_group" "sisense_linux" {
  name                = "sisense-${var.realm}-${var.environment}"
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
}

resource "azurerm_virtual_machine" "sisense_linux" {
  depends_on            = [azurerm_network_interface.sisense_linux, azurerm_managed_disk.sisense_linux]

  name                  = "sisense-linux-${var.realm}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_linux.id]
  vm_size               = "Standard_D8s_v3"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "sisense-os-${var.realm}-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "150"
  }

  os_profile {
    computer_name  = "sisense-linux"
    admin_username = var.sisense_linux_admin_username
    admin_password = var.sisense_linux_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
            path     = "/home/sisenseadmin/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAyorVg0eLKd2jwJuKaIaBP2IXAJ7henRGwcEf7cwc5iDUAa7fPPnGWYVzJ8nukV86D3ilkVltgtwtYB24cQSMGeAko6vmJUZIPIyNIPzlbiqbJksA3wHeTWRyEvAEJnITZ9R+4jnJZY0FB2VSmwM2x2vLDeP0BbElGhqRUWl6Qxr1ya/PTo/AXtAG+rbV8Oe2SYIZZuIN0aueD0CX/bFb+U/YQlqWNd99tkeTop5EbZJscL/HEmfkw4Yu1xuPrOmX+1/l22F9YshX46ec6S692QAXcDb8hFsjj4Pk3Px2yCNkX2j+6TycVHUHDbGzFEcCeHqpo96rFcNmULe+hzzGtQ=="
        }
  }

  storage_data_disk {
    name            = "sisense-data-${var.realm}-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_linux.id
    create_option   = "Attach"
    disk_size_gb    = "256"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_linux" {
  name                 = "sisense-data-${var.realm}-${var.environment}"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"

  tags = "${merge(
    local.common_tags
  )}"
  
  lifecycle{
    prevent_destroy = "true"
  }
}

resource "azurerm_public_ip" "sisense_linux" {
  name                         = "sisense-${var.realm}-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_linux" {
  depends_on                = [azurerm_public_ip.sisense_linux, azurerm_network_security_group.sisense_linux]
  name                      = "sisense-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_linux.id

  ip_configuration {
    name                          = "sisense-${var.realm}-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network_env.outputs.env-application_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_linux.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_recovery_services_protected_vm" "sisense_linux" {
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = "${data.terraform_remote_state.backup.outputs.vault}"
  source_vm_id        = "${azurerm_virtual_machine.sisense_linux.id}"
  backup_policy_id    = "${data.terraform_remote_state.backup.outputs.id_daily_14}"
}

resource "azurerm_private_dns_a_record" "sisense_linux" {
  name                = "sisense-linux.${var.environment}"
  zone_name           = data.terraform_remote_state.dns_realm.outputs.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.sisense_linux.private_ip_address]
}