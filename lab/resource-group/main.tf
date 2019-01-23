terraform {
  backend "azurerm" {
    access_key           = "gx3N29hLwW2OC+kO5FaAedBpjlh83kY35dpOrJZvdYAB+1CG5iHm85/763rJCiEZ6CY+cwSq+ZAVOvK8f2o4Hg=="
    storage_account_name = "terraformstatesapience"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"	
  }
}

provider "azurerm" {
  version = "1.20.0"
}

locals {
  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Lab"
    Component = "Resource Group"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_resource_group" "sapience" {
  name     = "LabEnvironment"
  location = "eastus"

  tags = "${merge(
    local.common_tags,
    map(
    )
  )}"
}
