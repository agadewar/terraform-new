terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
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
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

locals {
  environment = "dev"
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"
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