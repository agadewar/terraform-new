terraform {
  backend "azurerm" {
    key = "sapience.realm.global.resource-group.terraform.tfstate"
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
      "Component", "Resource Group"
    )
  )}"
}

resource "azurerm_resource_group" "sapience" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}
