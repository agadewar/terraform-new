#########################################
# SUMMARY
# - Network Security Group
# - Virtual Machines
#     - CGP-US-PROD-WEB-APP-001
#     - CGP-US-PROD-SQL-001
#########################################

#########################################
# TERRAFROM REMOTE STATE - (READ / WRITE)
#########################################
terraform {
  backend "azurerm" {
    key = "vm.tfstate"
  }
}

#########################################
# TERRAFORM REMOTE STATE - (READ-ONLY)
#########################################
data "terraform_remote_state" "network" {
  backend = "azurerm"
  config  = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.environment_backend_container_name
    key                  = "network.tfstate"
  }
}

#########################################
# AZURE PLUGIN
#########################################
provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

#########################################
# LOCAL VARIABLES
#########################################
locals {
  resource_name = "${var.realm}-${var.environment}"
  common_tags = merge(
    var.environment_common_tags,
    {
      Component = "VM"
    },
  )
}

#####################################################
# NETWORK SECURITY GROUP - WHITELIST SAPIENCE OFFICES
#####################################################
resource "azurerm_network_security_group" "sapience" {
  name                = local.resource_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

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

##################################
# VIRTUAL MACHINE - WEB APP SERVER
##################################
resource "azurerm_virtual_machine" "web_app_001" {
  name                  = "${local.resource_name}-web-app-001"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  depends_on            = [azurerm_network_interface.web_app_001]
  network_interface_ids = [azurerm_network_interface.web_app_001.id]
  vm_size               = "Standard_D4s_v3"

  ####################################################################################
  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  ####################################################################################
  delete_os_disk_on_termination = false

  ######################################################################################
  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  ######################################################################################
  delete_data_disks_on_termination = false

  #######################################
  # az vm image list --all --output table
  #######################################
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.resource_name}-web-app-001-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${local.resource_name}-web-app-001-data"
    managed_disk_id = azurerm_managed_disk.web_app_001_data.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
  
  os_profile {
    computer_name  = "WEB-APP-SVR-001"
    admin_username = var.cgp_us_prod_web_app_001_admin_username
    admin_password = var.cgp_us_prod_web_app_001_admin_password
  }
  
  os_profile_windows_config { 
    provision_vm_agent   = true
  }

  tags = "${merge(
      local.common_tags
  )}"
}

#########################################
# MANAGED DISK
#########################################
resource "azurerm_managed_disk" "web_app_001_data" {
  name                 = "${local.resource_name}-web-app-001-data"
  resource_group_name  = var.resource_group_name
    location           = var.resource_group_location
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

#########################################
# NETWORK INTERFACE
#########################################
resource "azurerm_network_interface" "web_app_001" {
  name                      = "${local.resource_name}-web-app-001"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  depends_on                = [azurerm_network_security_group.sapience]
  network_security_group_id = azurerm_network_security_group.sapience.id

  ip_configuration {
    name                          = "${local.resource_name}-web-app-001"
    subnet_id                     =  data.terraform_remote_state.network.outputs.env-application_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = "${merge(
      local.common_tags
  )}"
}

###############################################################################
# Virtual Machine Extension
# - https://jackstromberg.com/2018/11/using-terraform-with-azure-vm-extensions/
###############################################################################
resource "azurerm_virtual_machine_extension" "web_app_001" {
  name                 = "${local.resource_name}-web-app-001"
  resource_group_name  = var.resource_group_name
  location             = var.resource_group_location
  virtual_machine_name = azurerm_virtual_machine.web_app_001.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  
  settings = <<SETTINGS
    {
        "Name": "sapience.net",
        "User": "${var.domain_admin_username}",
        "OUPath": "",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
     {
        "Password": "${var.domain_admin_password}"
      }
    PROTECTED_SETTINGS
  depends_on = ["azurerm_virtual_machine.web_app_001"]

  tags = "${merge(
      local.common_tags
  )}"
}

##################################
# VIRTUAL MACHINE - WEB APP SERVER
##################################
resource "azurerm_virtual_machine" "sql_001" {
  name                  = "${local.resource_name}-sql-001"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  depends_on            = [azurerm_network_interface.sql_001]
  network_interface_ids = [azurerm_network_interface.sql_001.id]
  vm_size               = "Standard_D4s_v3"

  ####################################################################################
  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  ####################################################################################
  delete_os_disk_on_termination = false

  ######################################################################################
  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  ######################################################################################
  delete_data_disks_on_termination = false

  #######################################
  # az vm image list --all --output table
  #######################################
  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2016SP2-WS2016"
    sku       = "Standard"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${local.resource_name}-sql-001-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${local.resource_name}-sql-001-data"
    managed_disk_id = azurerm_managed_disk.sql_001_data.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
  
  os_profile {
    computer_name  = "SQL-SVR-001"
    admin_username = var.cgp_us_prod_sql_001_admin_username
    admin_password = var.cgp_us_prod_sql_001_admin_password
  }
  
  os_profile_windows_config { 
    provision_vm_agent   = true
  }

  tags = "${merge(
      local.common_tags
  )}"
}

#########################################
# MANAGED DISK
#########################################
resource "azurerm_managed_disk" "sql_001_data" {
  name                 = "${local.resource_name}-sql-001-data"
  resource_group_name  = var.resource_group_name
    location           = var.resource_group_location
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

#########################################
# NETWORK INTERFACE
#########################################
resource "azurerm_network_interface" "sql_001" {
  name                      = "${local.resource_name}-sql-001"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  depends_on                = [azurerm_network_security_group.sapience]
  network_security_group_id = azurerm_network_security_group.sapience.id

  ip_configuration {
    name                          = "${local.resource_name}-sql-001"
    subnet_id                     =  data.terraform_remote_state.network.outputs.env-data_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = "${merge(
      local.common_tags
  )}"
}

###############################################################################
# Virtual Machine Extension
# - https://jackstromberg.com/2018/11/using-terraform-with-azure-vm-extensions/
###############################################################################
resource "azurerm_virtual_machine_extension" "sql_001" {
  name                 = "${local.resource_name}-sql-001"
  resource_group_name  = var.resource_group_name
  location             = var.resource_group_location
  virtual_machine_name = azurerm_virtual_machine.sql_001.name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  
  settings = <<SETTINGS
    {
        "Name": "sapience.net",
        "User": "${var.domain_admin_username}",
        "OUPath": "",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
     {
        "Password": "${var.domain_admin_password}"
      }
    PROTECTED_SETTINGS
  depends_on = ["azurerm_virtual_machine.sql_001"]

  tags = "${merge(
      local.common_tags
  )}"
}


/* # VIRTUAL MACHINE - SQL SERVER
resource "azurerm_virtual_machine" "cgp_sql_001" {
  depends_on            = [azurerm_network_interface.cgp_sql_001]
  name                  = "cgp-sql-001-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.cgp_sql_001.id]
  vm_size               = "Standard_D4s_v3"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true


 # az vm image list --publisher MicrosoftSQLServer --all --output table
  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2016SP2-WS2016"
    sku       = "Standard"
    version   = "latest"
  }

  storage_os_disk {
    name              = "cgp-sql-os-001-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sql-${var.environment}-001"
    admin_username = var.cgp_sql_prod_001_admin_username
    admin_password = var.cgp_sql_prod_001_admin_password
  }

  os_profile_windows_config {
    provision_vm_agent   = true
  }

  storage_data_disk {
    name            = "cgp-sql-data-001-${var.environment}"
    managed_disk_id = azurerm_managed_disk.cgp_sql_data_001.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
  
  tags = "${merge(
      local.common_tags
  )}"
}

# MANAGED DISK
resource "azurerm_managed_disk" "cgp_sql_data_001" {
  name                 = "cgp-sql-data-001-${var.environment}"
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

# NETWORK INTERFACE
resource "azurerm_network_interface" "cgp_sql_001" {
  depends_on                = [azurerm_network_security_group.sapience-cgp]
  name                      = "cgp-sql-001-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sapience-cgp.id

  ip_configuration {
    name                          = "cgp-sql-001-${var.environment}"
    subnet_id                     =  data.terraform_remote_state.network_env.outputs.env-data_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

#azurerm_public_ip.sapience_cgp_001,
  tags = "${merge(
      local.common_tags
  )}"
}

resource "azurerm_virtual_machine_extension" "cgp-sql-001" {
  name                 = "cgp-sql-001-${var.environment}"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  virtual_machine_name = "${azurerm_virtual_machine.cgp_sql_001.name}"
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  
  settings = <<SETTINGS
    {
        "Name": "sapience.net",
        "User": "cgp-us-admin@sapience.net",
        "OUPath": "",
        "Restart": "true",
        "Options": "3"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
      {
        "Password": "skTkZmDjCKHejhATo-B9"
      }
    PROTECTED_SETTINGS
  depends_on = ["azurerm_virtual_machine.cgp_sql_001"]

  tags = "${merge(
      local.common_tags
  )}"
} */

