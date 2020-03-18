
# -------------------------------------------------------------------------------
# REMOVE TFSTATE FILE
# -------------------------------------------------------------------------------

terraform {
  backend "azurerm" {
    resource_group_name  = var.tfstate_resource_group
    storage_account_name = var.tfstate_storage_account
    container_name       = var.tfstate_container_name
    key                  = "${var.environment}.tfstate"
    access_key           = tfstate_access_key
  }
}

# -------------------------------------------------------------------------------
# Providers
# -------------------------------------------------------------------------------

provider "azurerm" {
  version         = "1.37.0"
  
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# -------------------------------------------------------------------------------
# MODULES
# - Resource Group
# -------------------------------------------------------------------------------

module "resource-group" {
  source          = "./modules/resource-group"

  environment     = var.environment
  location        = var.location
}