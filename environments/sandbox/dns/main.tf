terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.dns.terraform.tfstate"
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
    key                  = "sapience.sandbox.resource-group.terraform.tfstate"
  }
}

locals {
  environment = "${var.environment}"
  subscription_id = "${var.subscription_id}"
  backend_access_key = "${var.backend_access_key}"
  backend_storage_account_name = "${var.backend_storage_account_name}"
  backend_container_name = "${var.backend_container_name}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  common_tags = "${merge(
    var.common_tags,
      map(
        "Component", "DNS"
      )
  )}"
}

resource "azurerm_dns_zone" "dns_public" {
  name                = "${local.environment}.sapience.net"
  resource_group_name = "${local.resource_group_name}"
  zone_type           = "Public"
}