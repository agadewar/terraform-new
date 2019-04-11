terraform {
  backend "azurerm" {
    key = "sapience.realm.global.acrf.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

locals {
  realm = "${var.realm}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "ACR"
    )
  )}"
}

resource "azurerm_container_registry" "acr" {
  name                     = "${var.realm}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.resource_group_location}"
  sku                      = "Basic"
  admin_enabled            = "false"
  # georeplication_locations = ["East US", "West Europe"]

  tags = "${merge(
    local.common_tags,
    map()
  )}" 
}
