terraform {
  backend "azurerm" {
    key = "database.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

data "terraform_remote_state" "kubernetes_namespace" {
  backend = "azurerm"
  
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "environment-${var.environment}"
    key                  = "kubernetes-namespace.tfstate"
  }
}

locals {
  sql_server_version                = "12.0"
  sql_server_adminstrator_login     = "${var.sql_server_administrator_login}"
  sql_server_administrator_password = "${var.sql_server_administrator_password}"

  cosmos_failover_location = "eastus2"

  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Database"
    )
  )}"
}

resource "azurerm_sql_server" "sapience" {
  name                         = "sapience-${var.environment}"
  resource_group_name          = "${var.resource_group_name}"
  location                     = "${var.resource_group_location}"
  version                      = "${local.sql_server_version}"
  administrator_login          = "${var.sql_server_administrator_login}"
  administrator_login_password = "${var.sql_server_administrator_password}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_database" "device" {
  name                = "device"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  location            = "${azurerm_sql_server.sapience.location}"
  server_name         = "${azurerm_sql_server.sapience.name}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_database" "eventpipeline" {
  name                = "eventpipeline"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  location            = "${azurerm_sql_server.sapience.location}"
  server_name         = "${azurerm_sql_server.sapience.name}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_database" "leafbroker" {
  name                = "leafbroker"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  location            = "${azurerm_sql_server.sapience.location}"
  server_name         = "${azurerm_sql_server.sapience.name}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_database" "user" {
  name                = "user"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  location            = "${azurerm_sql_server.sapience.location}"
  server_name         = "${azurerm_sql_server.sapience.name}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_database" "mad" {
  name                = "mad"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  location            = "${azurerm_sql_server.sapience.location}"
  server_name         = "${azurerm_sql_server.sapience.name}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_firewall_rule" "aks_egress" {
  name                = "aks-egress"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "${data.terraform_remote_state.kubernetes_namespace.aks_egress_ip_address}"
  end_ip_address      = "${data.terraform_remote_state.kubernetes_namespace.aks_egress_ip_address}"
}

resource "azurerm_sql_firewall_rule" "sapience_office" {
  count = "${var.ip_sapience_office != "" ? 1 : 0}"

  name                = "sapience-office"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "${var.ip_sapience_office}"
  end_ip_address      = "${var.ip_sapience_office}"
}

resource "azurerm_sql_firewall_rule" "banyan_office" {
  count = "${var.ip_banyan_office != "" ? 1 : 0}"

  name                = "banyan-office"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "${var.ip_banyan_office}"
  end_ip_address      = "${var.ip_banyan_office}"
}

resource "azurerm_sql_firewall_rule" "steve_ardis_home" {
  count = "${var.ip_steve_ardis_home != "" ? 1 : 0}"

  name                = "steve-ardis-home"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "${var.ip_steve_ardis_home}"
  end_ip_address      = "${var.ip_steve_ardis_home}"
}

resource "azurerm_sql_firewall_rule" "benjamin_john_home" {
  count = "${var.ip_benjamin_john_home != "" ? 1 : 0}"

  name                = "benjamin-john-home"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "${var.ip_benjamin_john_home}"
  end_ip_address      = "${var.ip_benjamin_john_home}"
}

resource "azurerm_cosmosdb_account" "sapience_canopy_hierarchy" {
  name                = "sapience-canopy-hierarchy-${var.environment}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities = [
    {
      name = "EnableGremlin"
    }
  ]

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = "${local.cosmos_failover_location}"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_account" "sapience_graph" {
  name                = "sapience-graph-${var.environment}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities = [
    {
      name = "EnableGremlin"
    }
  ]

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = "${local.cosmos_failover_location}"
    failover_priority = 0
  }
}

# resource "azurerm_cosmosdb_account" "sapience_mdm" {
#   name                = "sapience-mdm-${local.environment}"
#   resource_group_name = "${local.resource_group_name}"
#   location            = "${local.resource_group_location}"
#   offer_type          = "Standard"
#   kind                = "GlobalDocumentDB"

# /*   capabilities = [
#     {
#       name = "MongoDBv3.4"
#     }
#   ] */

#   consistency_policy {
#     consistency_level = "Strong"
#   }

#   geo_location {
#     location          = "${local.cosmos_failover_location}"
#     failover_priority = 0
#   }
# }