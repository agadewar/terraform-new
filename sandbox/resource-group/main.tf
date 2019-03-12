terraform {
  backend "azurerm" {
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

locals {
  subscription_id = "${var.subscription_id}"

  resource_group_name = "Lab"

  common_tags = "${merge(
    var.common_tags,
      map(
        "Component", "Resource Group"
      )
  )}"
}

resource "azurerm_resource_group" "sapience" {
  name     = "${local.resource_group_name}"
  location = "eastus"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}
