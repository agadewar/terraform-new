terraform {
  backend "azurerm" {
    access_key           = "OPAUji+E5XV9vXAouVK5wt7u2ZTfdvVdifj8dUmOcRq9WGjQe5cyciqPZ23ZaffW1P5/GE29OzvLfhmUjl3HQg=="
    storage_account_name = "terraformstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.datalake.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "OPAUji+E5XV9vXAouVK5wt7u2ZTfdvVdifj8dUmOcRq9WGjQe5cyciqPZ23ZaffW1P5/GE29OzvLfhmUjl3HQg=="
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
    Component = "Data Lake"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_data_lake_store" "sapience" {
  name                = "sapience${local.environment}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  location            = "eastus2"
  encryption_state    = "Enabled"
  encryption_type     = "ServiceManaged"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_data_lake_store_firewall_rule" "ardis_home" {
  name                = "ardis-home"
  account_name        = "${azurerm_data_lake_store.sapience.name}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  start_ip_address    = "24.99.117.169"
  end_ip_address      = "24.99.117.169"
}

resource "azurerm_data_lake_store_firewall_rule" "banyan" {
  name                = "banyan"
  account_name        = "${azurerm_data_lake_store.sapience.name}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  start_ip_address    = "50.20.0.62"
  end_ip_address      = "50.20.0.62"
}
