terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

locals {
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"

  resource_group_name = "Lab"

  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Lab"
    Component = "Resource Group"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_resource_group" "sapience" {
  name     = "${local.resource_group_name}"
  location = "eastus"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}
