terraform {
  backend "azurerm" {
    key = "klov.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
}

locals {
  cosmos_failover_location              = "eastus2"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Klov"
    },
  )
}

resource "azurerm_cosmosdb_account" "klov" {
  name                = "klov-${var.realm}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}
