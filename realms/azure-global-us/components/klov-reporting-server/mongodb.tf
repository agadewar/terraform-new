locals {
  cosmos_failover_location              = "eastus2"
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
