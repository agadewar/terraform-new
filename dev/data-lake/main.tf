terraform {
  backend "azurerm" {
    key                  = "sapience.dev.data-lake.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "${local.backend_access_key}"
    storage_account_name = "${local.backend_storage_account_name}"
	  container_name       = "${local.backend_container_name}"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

locals {
  environment          = "${var.environment}"
  subscription_id      = "${var.subscription_id}"
  backend_access_key   = "${var.backend_access_key}"
  backend_storage_account_name = "${var.backend_storage_account_name}"
  backend_container_name       = "${var.backend_container_name}"
    common_tags = "${merge(
    var.common_tags,
      map(
        "Component", "Data Lake"
      )
  )}"
}

resource "azurerm_data_lake_store" "sapience" {
  name                = "sapience${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "eastus2"
  encryption_state    = "Enabled"
  encryption_type     = "ServiceManaged"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_data_lake_store_firewall_rule" "ardis_home" {
  name                = "ardis-home"
  account_name        = "${azurerm_data_lake_store.sapience.name}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  start_ip_address    = "24.99.117.169"
  end_ip_address      = "24.99.117.169"
}

resource "azurerm_data_lake_store_firewall_rule" "banyan" {
  name                = "banyan"
  account_name        = "${azurerm_data_lake_store.sapience.name}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  start_ip_address    = "50.20.0.62"
  end_ip_address      = "50.20.0.62"
}
