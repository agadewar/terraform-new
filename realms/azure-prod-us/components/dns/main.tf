terraform {
  backend "azurerm" {
    key = "dns.tfstate"
  }
}

provider "azurerm" {
  version         = "1.35.0"
  
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
  resource_group_name = "${var.resource_group_name}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "DNS"
    )
  )}"
}

resource "azurerm_private_dns_zone" "sapienceanalytics_com" {
  name                = "${var.dns_realm}.${var.region}.${var.cloud}.internal.sapienceanalytics.com"
  resource_group_name  = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "realm" {
  depends_on            = [azurerm_private_dns_zone.sapienceanalytics_com]

  name                  = var.dns_realm
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sapienceanalytics_com.name
  virtual_network_id    = data.terraform_remote_state.network.outputs.realm_network_id
}
