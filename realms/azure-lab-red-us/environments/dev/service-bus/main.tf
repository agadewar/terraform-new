terraform {
  backend "azurerm" {
    key = "service-bus.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
}

locals {
  common_tags = merge(
    var.realm_common_tags,
    var.environment_common_tags,
    {
      "Component" = "Service Bus"
    },
  )
}

resource "azurerm_servicebus_namespace" "namespace" {
  name                = "sapience-${var.realm}-${var.environment}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  capacity            = "0"

  tags = merge(local.common_tags, {})
}

resource "azurerm_servicebus_queue" "device_registration" {
  name                = "device-registration"
  resource_group_name = var.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.namespace.name

  enable_partitioning = false
}


