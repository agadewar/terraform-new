terraform {
  backend "azurerm" {
    access_key           = "tsHXP9evG4Azm/RNmmk5yxy18SaZ3RAoi2lKPxQvIPjtMgMsas3fe5tQiMOMMDzZsOeLJ1EtyhLXjHzI+wF2JQ=="
    storage_account_name = "terraformstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.service-bus.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "tsHXP9evG4Azm/RNmmk5yxy18SaZ3RAoi2lKPxQvIPjtMgMsas3fe5tQiMOMMDzZsOeLJ1EtyhLXjHzI+wF2JQ=="
    storage_account_name = "terraformstatelab"
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
