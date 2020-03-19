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
# - Virtual Network
# - Log Analytics Workspace
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
  version = "1.0.2"

  environment     = var.environment
}

# -------------------------------------------------------------------------------
# Virtual Network
# -------------------------------------------------------------------------------

module "network" {
  source  = "app.terraform.io/sapience-analytics/network/azurerm"
  version = "1.0.0"

  environment                                = var.environment
  virtual_network_address_space              = [ "10.0.0.0/16" ]
  subnet_default_address_prefix              = "10.0.0.0/20"
  subnet_application_address_prefix          = "10.0.16.0/20"
  subnet_data_address_prefix                 = "10.0.32.0/20"
  subnet_aks_default_pool_address_prefix     = "10.0.48.0/20"
  subnet_bastion_address_prefix              = "10.0.240.0/20"
}

# -------------------------------------------------------------------------------
# Log Analytics Workspace
# -------------------------------------------------------------------------------

module "loganalyticsworkspace" {
  source  = "app.terraform.io/sapience-analytics/loganalyticsworkspace/azurerm"
  version = "1.0.0"

  environment     = var.environment
}

# -------------------------------------------------------------------------------
# Kubernetes - Stateless - Black
# -------------------------------------------------------------------------------

module "kubernetes-stateless-black" {
  source  = "app.terraform.io/sapience-analytics/kubernetes/azurerm"
  version = "1.0.0"

  environment     = var.environment
  vnet_subnet_id  = module.network.aks_default_pool_subnet_id
}

# -------------------------------------------------------------------------------
# Kubernetes - Stateful - Black
# -------------------------------------------------------------------------------

module "kubernetes-stateful-black" {
  source  = "app.terraform.io/sapience-analytics/kubernetes/azurerm"
  version = "1.0.0"

  environment     = var.environment
  vnet_subnet_id  = module.network.aks_default_pool_subnet_id
  state           = "stateful"
}