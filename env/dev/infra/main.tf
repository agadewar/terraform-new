# -------------------------------------------------------------------------------
# Providers
# -------------------------------------------------------------------------------

provider "azurerm" {
  version = "2.0.0"
  features {} 

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

# -------------------------------------------------------------------------------
# MODULES
# - Resource Group
# - Blob Storage Account
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Resource Group
# -------------------------------------------------------------------------------

module "resourcegroup" {
  source  = "app.terraform.io/sapience-analytics/resourcegroup/azurerm"
  version = "1.0.0"

  environment     = var.environment
}

# -------------------------------------------------------------------------------
# Blob Storage Account
# -------------------------------------------------------------------------------

module "storageaccount" {
  source  = "app.terraform.io/sapience-analytics/storageaccount/azurerm"
  version = "1.0.0"

  environment     = var.environment
}