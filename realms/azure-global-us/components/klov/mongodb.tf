locals {
  cosmos_failover_location              = "eastus2"
}

resource "azurerm_cosmosdb_account" "klov" {
  name                = "klov-${var.realm}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableAggregationPipeline"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = local.cosmos_failover_location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "klov" {
  name                = "klov"
  resource_group_name = azurerm_cosmosdb_account.klov.resource_group_name
  account_name        = azurerm_cosmosdb_account.klov.name
}