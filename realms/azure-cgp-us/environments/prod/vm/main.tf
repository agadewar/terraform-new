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

data "terraform_remote_state" "network_env" {
  backend = "azurerm"

  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = var.env_backend_container_name
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

# NETWORK SECURITY GROUP
resource "azurerm_network_security_group" "sapience-cgp" {
  name                = "sapience-cgp-${var.environment}"
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
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.ip_sapience_pune_office
    destination_address_prefix = "*"
  } 
  
  tags = "${merge(
      local.common_tags
  )}"
}

# DEMO VIRTUAL MACHINE
resource "azurerm_virtual_machine" "sapience_cgp_001" {
  depends_on            = [azurerm_network_interface.sapience_cgp_001]
  name                  = "sapience-cgp-001-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sapience_cgp_001.id]
  vm_size               = "Standard_D4s_v3"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

 # https://docs.microsoft.com/th-th/azure/virtual-machines/windows/cli-ps-findimage
 # az vm image list --publisher MicrosoftSQLServer --all --output table
  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2016SP2-WS2016"
    sku       = "Standard"
    version   = "latest"
  }

  storage_os_disk {
    name              = "sapience-cgp-os-001-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sapcgp-prod001"
    admin_username = var.sapience_cgp_prod_admin_username
    admin_password = var.sapience_cgp_prod_admin_password
  }

  os_profile_windows_config {}

  storage_data_disk {
    name            = "sapience-cgp-data-001-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sapience_cgp_data_001.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
  
  tags = "${merge(
      local.common_tags
  )}"
}

# MANAGED DISK
resource "azurerm_managed_disk" "sapience_cgp_data_001" {
  name                 = "sapience-cgp-data-001-${var.environment}"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "100"

  tags = "${merge(
    local.common_tags
  )}"
  
  lifecycle{
    prevent_destroy = "false"
  }
}

# PUBLIC IP ADDRESS
resource "azurerm_public_ip" "sapience_cgp_001" {
  name                         = "sapience-cgp-001-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
  
  tags = "${merge(
      local.common_tags
  )}"
}

# NETWORK INTERFACE
resource "azurerm_network_interface" "sapience_cgp_001" {
  depends_on                = [azurerm_public_ip.sapience_cgp_001, azurerm_network_security_group.sapience-cgp]
  name                      = "sapience-cgp-001-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sapience-cgp.id

  ip_configuration {
    name                          = "sapience-cgp-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network_env.outputs.env-application_subnet_id
    public_ip_address_id          = azurerm_public_ip.sapience_cgp_001.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = "${merge(
      local.common_tags
  )}"
}

resource "azurerm_recovery_services_protected_vm" "sapience_cgp_001" {
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = "${data.terraform_remote_state.backup.outputs.vault}"
  source_vm_id        = "${azurerm_virtual_machine.sapience_cgp_001.id}"
  backup_policy_id    = "${data.terraform_remote_state.backup.outputs.id_daily_14}"
}
