terraform {
  backend "azurerm" {
    key = "sapience.realm.global.network.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

locals {
  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Network"
    )
  )}"
}

resource "azurerm_virtual_network" "default" {
  name                 = "${var.resource_group_name}-vnet"
  location             = "${var.resource_group_location}"
  address_space        = ["172.16.1.0/24"]
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.default.name}"
  address_prefix       = "172.16.1.0/24"
}
