terraform {
  backend "azurerm" {
    access_key           = "gx3N29hLwW2OC+kO5FaAedBpjlh83kY35dpOrJZvdYAB+1CG5iHm85/763rJCiEZ6CY+cwSq+ZAVOvK8f2o4Hg=="
    storage_account_name = "terraformstatesapience"
	  container_name       = "tfstate"
    key                  = "sapience.dev.eventhubs.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "gx3N29hLwW2OC+kO5FaAedBpjlh83kY35dpOrJZvdYAB+1CG5iHm85/763rJCiEZ6CY+cwSq+ZAVOvK8f2o4Hg=="
    storage_account_name = "terraformstatesapience"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

locals {
  environment = "dev"

  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Dev"
    Component = "Event Hubs"
    ManagedBy = "Terraform"
  }
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