terraform {
  backend "azurerm" {
    key = "resource-group.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

locals {
  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Resource Group"
    )
  )}"
}

variable "prefix" {
  default = "Web-App-Svr-001"
}

resource "azurerm_resource_group" "sapience" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}


resource "azurerm_network_interface" "sapience" {
  name                = "${var.prefix}-nic"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"

  ip_configuration {
    name                          = "${var.prefix}-ip"
    subnet_id                     = "/subscriptions/c57d6dfd-85ff-46a6-8038-1f6d97197cb6/resourceGroups/CGP-Sandbox/providers/Microsoft.Network/virtualNetworks/CGP-Sandbox-vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "sapience" {
  name                  = "${var.prefix}"
  location              = "${var.resource_group_location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${azurerm_network_interface.sapience.id}"]
  vm_size               = "Standard_F4s"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "datadisk_01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }
  os_profile_windows_config {
    provision_vm_agent=true
  }
  tags = {
    environment = "CGP-Sandbox"
  }
}

resource "azurerm_managed_disk" "sapience" {
  name                 = "${var.prefix}-disk1"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 500
}

resource "azurerm_virtual_machine_data_disk_attachment" "sapience" {
  managed_disk_id    = "${azurerm_managed_disk.sapience.id}"
  virtual_machine_id = "${azurerm_virtual_machine.sapience.id}"
  lun                = "10"
  caching            = "ReadWrite"
}