terraform {
  backend "azurerm" {
    key = "sapience.environment.dev.event-hubs.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

locals {
  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Event Hubs"
    )
  )}"
}

resource "azurerm_eventhub_namespace" "sapience_event_hub_journal" {
  name                = "sapience-event-hub-journal-${var.environment}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
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
