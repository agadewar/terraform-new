terraform {
  backend "azurerm" {
    key = "sapience.environment.sandbox.database.terraform.tfstate"
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
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.environment.${var.environment}.kubernetes-namespace.terraform.tfstate"
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

resource "azurerm_sql_database" "mdm" {
  name                = "mdm"
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

resource "azurerm_sql_firewall_rule" "ardis_home" {
  name                = "ardis-home"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "24.99.117.169"
  end_ip_address      = "24.99.117.169"
}

resource "azurerm_sql_firewall_rule" "banyan" {
  name                = "banyan"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "50.20.0.62"
  end_ip_address      = "50.20.0.62"
}
resource "azurerm_sql_firewall_rule" "azure_portal" {
  name                = "azure-portal"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "40.76.27.62"
  end_ip_address      = "40.76.27.62"
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