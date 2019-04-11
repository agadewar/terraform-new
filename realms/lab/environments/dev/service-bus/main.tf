terraform {
  backend "azurerm" {
    key = "sapience.environment.dev.service-bus.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

# data "terraform_remote_state" "resource_group" {
#   backend = "azurerm"
#   config {
#     access_key           = "${var.backend_access_key}"
#     storage_account_name = "${var.backend_storage_account_name}"
# 	  container_name       = "${var.backend_container_name}"
#     key                  = "sapience.environment.sandbox.resource-group.terraform.tfstate"
#   }
# }

locals {
  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Service Bus"
    )
  )}"
}

resource "azurerm_servicebus_namespace" "namespace" {
  name                = "sapience-${var.environment}"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
  sku                 = "Standard"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_servicebus_queue" "canopy_eventpipeline" {
  name                = "sapience-canopy-eventpipeline"
  resource_group_name = "${var.resource_group_name}"
  namespace_name      = "${azurerm_servicebus_namespace.namespace.name}"

  enable_partitioning = true
}

resource "azurerm_servicebus_queue" "canopy_datalake" {
  name                = "sapience-canopy-datalake"
  resource_group_name = "${var.resource_group_name}"
  namespace_name      = "${azurerm_servicebus_namespace.namespace.name}"

  enable_partitioning = true
}
