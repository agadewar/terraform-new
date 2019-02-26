terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
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
    Component = "Service Bus"
    ManagedBy = "Terraform"
  }
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
