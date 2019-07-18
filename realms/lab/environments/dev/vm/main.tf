terraform {
  backend "azurerm" {
    key = "vm.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "network.tfstate"
  }
}

locals {
  common_tags = merge(
    var.environment_common_tags,
    {
      Component = "VM"
    },
  )
}


resource "azurerm_network_security_group" "sisense_appquery" {
  name                = "sisense-appquery-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-AllTraffic-Sapience-Office"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_sapience_office
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "Allow-AllTraffic-Banyan-Office"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_banyan_office
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-AllTraffic-BenjaminJohn-Home"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_benjamin_john_home
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-AllTraffic-SteveArdis-Home"
    priority                   = 202
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_steve_ardis_home
    destination_address_prefix = "*"
  }
}

# Sisense App/Query Server 01

resource "azurerm_virtual_machine" "sisense_appquery_01" {
  depends_on            = [azurerm_network_interface.sisense_appquery_01]
  name                  = "sisense-appquery-vm-01-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_appquery_01.id]
  vm_size               = "Standard_A8_v2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "sisense-appquery-01-os-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sisense-appq01"
    admin_username = var.sisense_appquery_01_admin_username
    admin_password = var.sisense_appquery_01_admin_password
  }

  os_profile_windows_config {}

  storage_data_disk {
    name            = "sisense-appquery-01-data-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_appquery_01_data.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_appquery_01_data" {
  name                 = "sisense-appquery-01-data-${var.environment}"
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

resource "azurerm_public_ip" "sisense_appquery_01" {
  name                         = "sisense-appquery-01-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_appquery_01" {
  depends_on                = [azurerm_public_ip.sisense_appquery_01, azurerm_network_security_group.sisense_appquery]
  name                      = "sisense-appquery-01-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_appquery.id

  ip_configuration {
    name                          = "sisense-appquery-01-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network.outputs.default_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_appquery_01.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Sisense App/Query Server 02

resource "azurerm_virtual_machine" "sisense_appquery_02" {
  depends_on            = [azurerm_network_interface.sisense_appquery_02]
  name                  = "sisense-appquery-vm-02-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_appquery_02.id]
  vm_size               = "Standard_A8_v2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "sisense-appquery-02-os-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sisense-appq02"
    admin_username = var.sisense_appquery_02_admin_username
    admin_password = var.sisense_appquery_02_admin_password
  }

  os_profile_windows_config {}

  storage_data_disk {
    name            = "sisense-appquery-02-data-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_appquery_02_data.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_appquery_02_data" {
  name                 = "sisense-appquery-02-data-${var.environment}"
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

resource "azurerm_public_ip" "sisense_appquery_02" {
  name                         = "sisense-appquery-02-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_appquery_02" {
  depends_on                = [azurerm_public_ip.sisense_appquery_02, azurerm_network_security_group.sisense_appquery]
  name                      = "sisense-appquery-02-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_appquery.id

  ip_configuration {
    name                          = "sisense-appquery-02-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network.outputs.default_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_appquery_02.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Sisense Build Server

resource "azurerm_network_security_group" "sisense_build" {
  name                = "sisense-build-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow-AllTraffic-Sapience-Office"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_sapience_office
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "Allow-AllTraffic-Banyan-Office"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_banyan_office
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-AllTraffic-BenjaminJohn-Home"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_benjamin_john_home
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-AllTraffic-SteveArdis-Home"
    priority                   = 202
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_steve_ardis_home
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_machine" "sisense_build" {
  depends_on            = [azurerm_network_interface.sisense_build]
  name                  = "sisense-build-vm-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_build.id]
  vm_size               = "Standard_A8_v2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "sisense-build-os-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sisense-build"
    admin_username = var.sisense_build_admin_username
    admin_password = var.sisense_build_admin_password
  }

  os_profile_windows_config {}

  storage_data_disk {
    name            = "sisense-build-data-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_build_data.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_build_data" {
  name                 = "sisense-build-data-${var.environment}"
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

resource "azurerm_public_ip" "sisense_build" {
  name                         = "sisense-build-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_build" {
  depends_on                = [azurerm_public_ip.sisense_build, azurerm_network_security_group.sisense_build]
  name                      = "sisense-build-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_build.id

  ip_configuration {
    name                          = "sisense-build-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network.outputs.default_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_build.id
    private_ip_address_allocation = "Dynamic"
  }
}