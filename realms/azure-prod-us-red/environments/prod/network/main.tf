terraform {
  backend "azurerm" {
    key = "red/network.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

data "terraform_remote_state" "network_realm" {
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
    var.realm_common_tags,
    {
      "Component" = "Network"
    },
  )
}

resource "azurerm_subnet" "env-default" {
  name                 = "${var.environment}-default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.subnet_address_prefix_env-default
}

resource "azurerm_subnet" "env-application" {
  name                 = "${var.environment}-application"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.subnet_address_prefix_env-application
}

resource "azurerm_subnet" "env-data" {
  name                 = "${var.environment}-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.subnet_address_prefix_env-data
}

