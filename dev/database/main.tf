terraform {
  backend "azurerm" {
    access_key           = "lo8HUaHNNDrFRHsTL+5uNuykv+WfQSHNxgXWqdcxE2vbk/eiSgaZx+gP2bHdU9TWKJk+PqhhyB0wY95wOCLDoQ=="
    storage_account_name = "tfstatelower"
	  container_name       = "tfstate"
    key                  = "sapience.dev.database.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "lo8HUaHNNDrFRHsTL+5uNuykv+WfQSHNxgXWqdcxE2vbk/eiSgaZx+gP2bHdU9TWKJk+PqhhyB0wY95wOCLDoQ=="
    storage_account_name = "tfstatelower"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"
  config {
    access_key           = "lo8HUaHNNDrFRHsTL+5uNuykv+WfQSHNxgXWqdcxE2vbk/eiSgaZx+gP2bHdU9TWKJk+PqhhyB0wY95wOCLDoQ=="
    storage_account_name = "tfstatelower"
	  container_name       = "tfstate"
    key                  = "sapience.lab.kubernetes.terraform.tfstate"
  }
}

locals {
  Environment = "sandbox"
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"
  cosmos_failover_location = "eastus2"

  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "sandbox"
    Component = "Database"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_sql_server" "sapience" {
  name                         = "sapience-${local.environment}"
  resource_group_name          = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location                     = "${data.terraform_remote_state.resource_group.resource_group_location}"
  version                      = "12.0"
  administrator_login          = "sapience"
  administrator_login_password = "45L2x9;j53_h22B3gpt962r1"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_sql_firewall_rule" "aks_egress" {
  name                = "aks-egress"
  resource_group_name = "${azurerm_sql_server.sapience.resource_group_name}"
  server_name         = "${azurerm_sql_server.sapience.name}"
  start_ip_address    = "${data.terraform_remote_state.kubernetes.aks_egress_dev_ip_address}"
  end_ip_address      = "${data.terraform_remote_state.kubernetes.aks_egress_dev_ip_address}"
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

resource "azurerm_cosmosdb_account" "mdm" {
  name                = "sapience-mdm-${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  capabilities = [
    {
      name = "EnableGremlin"
    }
  ]

  enable_automatic_failover = false

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = "${local.cosmos_failover_location}"
    failover_priority = 0
  }
}
