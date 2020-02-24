terraform {
  backend "azurerm" {
    key = "vm.tfstate"
  }
}

provider "azurerm" {
  version         = "1.44.0"

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

data "terraform_remote_state" "backup" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "backup.tfstate"
  }
}

data "terraform_remote_state" "dns_realm" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "dns.tfstate"
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

# SECURITY GROUPS

resource "azurerm_network_security_group" "sisense_appquery" {
  name                = "sisense-appquery-${var.realm}-${var.environment}"
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

resource "azurerm_network_security_group" "sisense_build" {
  name                = "sisense-build-${var.realm}-${var.environment}"
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

# VIRTUAL MACHINES

resource "azurerm_virtual_machine" "sisense_appquery_001" {
  depends_on            = [azurerm_network_interface.sisense_appquery_001]

  name                  = "sisense-appquery-001-${var.realm}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_appquery_001.id]
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
    name              = "sisense-appquery-os-001-${var.realm}-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sisense-appq001"
    admin_username = var.sisense_appquery_001_admin_username
    admin_password = var.sisense_appquery_001_admin_password
  }

  //Enabled will re-create VM.
  /* os_profile_windows_config {
    provision_vm_agent = true
  } */

  storage_data_disk {
    name            = "sisense-appquery-data-001-${var.realm}-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_appquery_data_001.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_appquery_data_001" {
  name                 = "sisense-appquery-data-001-${var.realm}-${var.environment}"
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

resource "azurerm_public_ip" "sisense_appquery_001" {
  name                         = "sisense-appquery-001-${var.realm}-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_appquery_001" {
  depends_on                = [azurerm_public_ip.sisense_appquery_001, azurerm_network_security_group.sisense_appquery]
  name                      = "sisense-appquery-001-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_appquery.id

  ip_configuration {
    name                          = "sisense-appquery-001-${var.realm}-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network_env.outputs.env-application_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_appquery_001.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_recovery_services_protected_vm" "sisense_appquery_001" {
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = "${data.terraform_remote_state.backup.outputs.vault}"
  source_vm_id        = "${azurerm_virtual_machine.sisense_appquery_001.id}"
  backup_policy_id    = "${data.terraform_remote_state.backup.outputs.id_daily_14}"
}

resource "azurerm_private_dns_a_record" "sisense_appquery_001" {
  name                = "sisense-appquery-001.${var.environment}"
  zone_name           = data.terraform_remote_state.dns_realm.outputs.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.sisense_appquery_001.private_ip_address]
}

resource "azurerm_virtual_machine" "sisense_appquery_002" {
  depends_on            = [azurerm_network_interface.sisense_appquery_002]
  name                  = "sisense-appquery-002-${var.realm}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_appquery_002.id]
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
    name              = "sisense-appquery-os-002-${var.realm}-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sisense-appq002"
    admin_username = var.sisense_appquery_002_admin_username
    admin_password = var.sisense_appquery_002_admin_password
  }

  os_profile_windows_config {}

  storage_data_disk {
    name            = "sisense-appquery-data-002-${var.realm}-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_appquery_data_002.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_appquery_data_002" {
  name                 = "sisense-appquery-data-002-${var.realm}-${var.environment}"
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

resource "azurerm_public_ip" "sisense_appquery_002" {
  name                         = "sisense-appquery-002-${var.realm}-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_appquery_002" {
  depends_on                = [azurerm_public_ip.sisense_appquery_002, azurerm_network_security_group.sisense_appquery]
  name                      = "sisense-appquery-002-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_appquery.id

  ip_configuration {
    name                          = "sisense-appquery-002-${var.realm}-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network_env.outputs.env-application_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_appquery_002.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_recovery_services_protected_vm" "sisense_appquery_002" {
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = "${data.terraform_remote_state.backup.outputs.vault}"
  source_vm_id        = "${azurerm_virtual_machine.sisense_appquery_002.id}"
  backup_policy_id    = "${data.terraform_remote_state.backup.outputs.id_daily_14}"
}

resource "azurerm_private_dns_a_record" "sisense_appquery_002" {
  name                = "sisense-appquery-002.${var.environment}"
  zone_name           = data.terraform_remote_state.dns_realm.outputs.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.sisense_appquery_002.private_ip_address]
}

resource "azurerm_virtual_machine" "sisense_build_001" {
  depends_on            = [azurerm_network_interface.sisense_build_001]
  name                  = "sisense-build-001-${var.realm}-${var.environment}"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  network_interface_ids = [azurerm_network_interface.sisense_build_001.id]
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
    name              = "sisense-build-os-001-${var.realm}-${var.environment}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "sisense-bld001"
    admin_username = var.sisense_build_001_admin_username
    admin_password = var.sisense_build_001_admin_password
  }

  os_profile_windows_config {}

  storage_data_disk {
    name            = "sisense-build-data-001-${var.realm}-${var.environment}"
    managed_disk_id = azurerm_managed_disk.sisense_build_data_001.id
    create_option   = "Attach"
    disk_size_gb    = "100"
    lun             = "1"
  }
}

resource "azurerm_managed_disk" "sisense_build_data_001" {
  name                 = "sisense-build-data-001-${var.realm}-${var.environment}"
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

resource "azurerm_public_ip" "sisense_build_001" {
  name                         = "sisense-build-001-${var.realm}-${var.environment}"
  location                     = "East US"
  resource_group_name          = var.resource_group_name
  public_ip_address_allocation = "Static"
}

resource "azurerm_network_interface" "sisense_build_001" {
  depends_on                = [azurerm_public_ip.sisense_build_001, azurerm_network_security_group.sisense_build]
  name                      = "sisense-build-001-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  network_security_group_id = azurerm_network_security_group.sisense_build.id

  ip_configuration {
    name                          = "sisense-build-001-${var.realm}-${var.environment}"
    subnet_id                     = data.terraform_remote_state.network_env.outputs.env-application_subnet_id
    public_ip_address_id          = azurerm_public_ip.sisense_build_001.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_recovery_services_protected_vm" "sisense_build_001" {
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = "${data.terraform_remote_state.backup.outputs.vault}"
  source_vm_id        = "${azurerm_virtual_machine.sisense_build_001.id}"
  backup_policy_id    = "${data.terraform_remote_state.backup.outputs.id_daily_14}"
}

resource "azurerm_private_dns_a_record" "sisense_build_001" {
  name                = "sisense-build-001.${var.environment}"
  zone_name           = data.terraform_remote_state.dns_realm.outputs.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_network_interface.sisense_build_001.private_ip_address]
}

resource "azurerm_private_dns_a_record" "sisense_appquery" {
  name                = "sisense.${var.environment}"
  zone_name           = data.terraform_remote_state.dns_realm.outputs.private_dns_zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records = [azurerm_network_interface.sisense_appquery_001.private_ip_address,
             azurerm_network_interface.sisense_appquery_002.private_ip_address]
}