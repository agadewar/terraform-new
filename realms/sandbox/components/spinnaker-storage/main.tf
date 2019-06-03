terraform {
  backend "azurerm" {
    key = "spinnaker-storage.tfstate"
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
      "Component", "Spinnaker Storage"
    )
  )}"
}

resource "azurerm_storage_account" "spinnaker_storage" {
  name                      = "spinnakerstorage${var.realm}"
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.resource_group_location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

# resource "azurerm_storage_share" "spinnaker_storage" {
#   name = "spinnaker-storage"

#   resource_group_name       = "${var.resource_group_name}"
#   storage_account_name = "${azurerm_storage_account.spinnaker_storage.name}"

#   quota = 20
# }