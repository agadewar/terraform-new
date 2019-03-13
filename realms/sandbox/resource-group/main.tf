terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.sandbox.resource-group.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

locals {
  subscription_id = "c57d6dfd-85ff-46a6-8038-1f6d97197cb6"

  resource_group_name = "Sandbox"

  resource_group_location = "eastus"

  realm = "sandbox"
  common_tags = "${map(
    "Customer", "Sapience",
    "Product", "Sapience",
    "Realm", "Sandbox",
    "Component", "Init",
    "ManagedBy", "Terraform"
  )}"
}

resource "azurerm_resource_group" "sapience" {
  name     = "${local.resource_group_name}"
  location = "${local.resource_group_location}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}
