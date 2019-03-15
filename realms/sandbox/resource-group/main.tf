terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.sandbox.resource-group.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

# locals {
#   subscription_id = "${var.subscription_id}"

#   resource_group_name = "${var.resource_group_name}"

#   resource_group_location = "${var.resource_group_location}"

#   realm = "${var.realm}"
  
#   common_tags = "${merge(
#     var.common_tags,
#       map(
#         "Component", "Resource Group"
#       )
#   )}"
# }

resource "azurerm_resource_group" "sapience" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}
