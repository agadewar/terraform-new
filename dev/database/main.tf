terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.database.terraform.tfstate"
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

data "terraform_remote_state" "kubernetes_namespace" {
  backend = "azurerm"
  
  config {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.kubernetes-namespace.terraform.tfstate"
  }
}

locals {
  environment = "dev"
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"
  sql_server_version = "12.0"
  sql_server_adminstrator_login = "sapience"
  sql_server_administrator_password = "45L2x9;j53_h22B3gpt962r1"
  cosmos_failover_location = "eastus2"

  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Dev"
    Component = "Database"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_sql_server" "sapience" {
  name                         = "sapience-${local.environment}"
  resource_group_name          = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location                     = "${data.terraform_remote_state.resource_group.resource_group_location}"
  version                      = "${local.sql_server_version}"
  administrator_login          = "${local.sql_server_adminstrator_login}"
  administrator_login_password = "${local.sql_server_administrator_password}"

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

resource "azurerm_cosmosdb_account" "sapience_canopy_hierarchy" {
  name                = "sapience-canopy-hierarchy-${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
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
  name                = "sapience-graph-${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
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

resource "azurerm_cosmosdb_account" "sapience_mdm" {
  name                = "sapience-mdm-${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities = [
    {
      name = "MongoDBv3.4"
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