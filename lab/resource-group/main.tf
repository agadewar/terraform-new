terraform {
  backend "azurerm" {
    access_key           = "tsHXP9evG4Azm/RNmmk5yxy18SaZ3RAoi2lKPxQvIPjtMgMsas3fe5tQiMOMMDzZsOeLJ1EtyhLXjHzI+wF2JQ=="
    storage_account_name = "terraformstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"	
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"

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
    map()
  )}"
}
