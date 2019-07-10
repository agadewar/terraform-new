terraform {
  backend "azurerm" {
    key = "resource-group.tfstate"
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
  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Resource Group"
    )
  )}"
}

resource "azurerm_resource_group" "sapience" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags = "${merge(
    local.common_tags
  )}"
}
