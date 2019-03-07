terraform {
  backend "azurerm" {
    key                  = "sapience.dev.service-bus.terraform.tfstate"
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
  environment = "${var.environment}"
  subscription_id = "${var.subscription_id}"
  backend_access_key = "${var.backend_access_key}"
  backend_storage_account_name = "${var.backend_storage_account_name}"
  backend_container_name = "${var.backend_container_name}"
  common_tags = "${merge(
    var.common_tags,
      map(
        "Component", "Service Bus"
      )
  )}"
}

resource "azurerm_servicebus_namespace" "namespace" {
  name                = "sapience-${local.environment}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  sku                 = "Standard"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_servicebus_queue" "canopy_eventpipeline" {
  name                = "sapience-canopy-eventpipeline"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  namespace_name      = "${azurerm_servicebus_namespace.namespace.name}"

  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "canopy_datalake" {
  name                = "sapience-canopy-datalake"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  namespace_name      = "${azurerm_servicebus_namespace.namespace.name}"

  enable_partitioning = true
}
