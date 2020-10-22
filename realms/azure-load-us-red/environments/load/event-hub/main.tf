terraform {
  backend "azurerm" {
    key = "event-hub.tfstate"
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


resource "azurerm_eventhub_namespace" "namespace" {
  name                     = "sapience-eventhub-${var.realm}-${var.environment}"
  location                 = var.resource_group_location
  resource_group_name      = var.resource_group_name
  sku                      = "Standard"
  kafka_enabled            = true
  capacity                 = 1
  auto_inflate_enabled     = true
  maximum_throughput_units = 20
}

resource "azurerm_eventhub" "canopy-eventpipeline" {
  name                = "canopy-eventpipeline"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  partition_count     = 32
  message_retention   = 3
}

resource "azurerm_eventhub" "eventarchive-channel" {
  name                = "eventarchive-channel"
  namespace_name      = azurerm_eventhub_namespace.namespace.name
  resource_group_name = var.resource_group_name
  partition_count     = 32
  message_retention   = 3
}