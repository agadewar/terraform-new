terraform {
  backend "azurerm" {
    key                  = "sapience.dev.event-hubs.terraform.tfstate"
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
        "Component", "Event Hubs"
      )
  )}"
}

resource "azurerm_eventhub_namespace" "sapience_event_hub_journal" {
  name                = "sapience-event-hub-journal-${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
  sku                 = "Standard"
  capacity            = 1
  # kafka_enabled       = false

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_eventhub" "datalake" {
  name                = "datalake"
  namespace_name      = "${azurerm_eventhub_namespace.sapience_event_hub_journal.name}"
  resource_group_name = "${azurerm_eventhub_namespace.sapience_event_hub_journal.resource_group_name}"
  partition_count     = 2
  message_retention   = 1
}
