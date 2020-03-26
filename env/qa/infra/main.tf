# -------------------------------------------------------------------------------
# REMOTE TFSTATE FILE
# -------------------------------------------------------------------------------

terraform {
  backend "azurerm" {
    key = "${var.environment}-${var.location}.tfstate"
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
  source          = "../modules/resource-group"

  environment     = var.environment
  location        = var.location
}