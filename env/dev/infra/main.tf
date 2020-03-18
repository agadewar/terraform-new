# -------------------------------------------------------------------------------
# Providers
# -------------------------------------------------------------------------------

provider "azurerm" {
  
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

# -------------------------------------------------------------------------------
# MODULES
# - Resource Group
# -------------------------------------------------------------------------------

module "resourcegroup" {
  source  = "app.terraform.io/sapience-analytics/resourcegroup/azurerm"

  environment     = var.environment
}