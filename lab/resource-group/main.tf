terraform {
  backend "azurerm" {
    access_key           = "OPAUji+E5XV9vXAouVK5wt7u2ZTfdvVdifj8dUmOcRq9WGjQe5cyciqPZ23ZaffW1P5/GE29OzvLfhmUjl3HQg=="
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
