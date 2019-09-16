terraform {
  backend "azurerm" {
    key = "backup.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

locals {
  resource_group_name = "${var.resource_group_name}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Backup"
    )
  )}"
}

resource "azurerm_recovery_services_vault" "vault" {
  name                = "${var.realm}-vault"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
  sku                 = "Standard"
}

resource "azurerm_recovery_services_protection_policy_vm" "daily_14" {
  name                = "Daily-14"
  resource_group_name = "${var.resource_group_name}"
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 14
  }
}

# The VMs must have the Azure VM Agent installed.  https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/agent-windows