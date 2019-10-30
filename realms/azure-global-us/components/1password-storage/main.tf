terraform {
  backend "azurerm" {
    key = "password-storage.tfstate"
  }
}

provider "azurerm" {
  version = "1.35.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

locals {
  realm = "${var.realm}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "1Password Storage"
    )
  )}"
}

data "terraform_remote_state" "storage_account" {
  backend = "azurerm"

  config = {
    access_key            = var.realm_backend_access_key
    storage_account_name  = var.realm_backend_storage_account_name
	  container_name        = var.realm_backend_container_name
    key                   = "storage-account.tfstate"
  }
}

resource "azurerm_managed_disk" "password_home" {
  name                 = "password-home"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = "${merge(
    local.common_tags
  )}"
  
  lifecycle{
    prevent_destroy = "true"
  }
}