terraform {
  backend "azurerm" {
    key = "sonarqube-storage.tfstate"
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
  realm = "${var.realm}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Sonarqube Storage"
    )
  )}"
}

data "terraform_remote_state" "storage_account" {
  backend = "azurerm"

  config = {
    access_key            = "${var.backend_access_key}"
    storage_account_name  = "${var.backend_storage_account_name}"
	container_name        = "realm-${var.realm}"
    key                   = "storage-account.tfstate"
  }
}

// resource "azurerm_storage_account" "storage_account" {
//   name                      = "sapiencerealm${var.realm}"
//   resource_group_name       = "${var.resource_group_name}"
//   location                  = "${var.resource_group_location}"
//   account_tier              = "Standard"
//   account_replication_type  = "LRS"
//   account_kind              = "StorageV2"
//   enable_https_traffic_only = "true"

//   tags = "${merge(
//     local.common_tags
//   )}"

//   lifecycle {
//     prevent_destroy = "true"
//   }
// }

resource "azurerm_storage_container" "sonarqube" {
  name                  = "sonarqube"
  resource_group_name   = "${var.resource_group_name}"
  storage_account_name  = "${data.terraform_remote_state.storage_account.outputs.storage_account_name}"
  container_access_type = "private"
}

# resource "azurerm_storage_share" "spinnaker_storage" {
#   name = "spinnaker-storage"

#   resource_group_name       = "${var.resource_group_name}"
#   storage_account_name = "${azurerm_storage_account.spinnaker_storage.name}"

#   quota = 20
# }