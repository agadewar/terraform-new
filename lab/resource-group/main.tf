terraform {
  backend "azurerm" {
    access_key           = "lo8HUaHNNDrFRHsTL+5uNuykv+WfQSHNxgXWqdcxE2vbk/eiSgaZx+gP2bHdU9TWKJk+PqhhyB0wY95wOCLDoQ=="
    storage_account_name = "tfstatelower"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
}

locals {
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"

  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "sandbox"
    Component = "Resource Group"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_resource_group" "sapience" {
  name     = "LabEnvironment"
  location = "eastus"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}
