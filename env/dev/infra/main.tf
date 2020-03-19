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
# - Kubernetes Cluster (Stateless)
# - Kubernetes Cluster (Stateful)
# - Service Bus
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
# Resource Group
# -------------------------------------------------------------------------------

module "resourcegroup" {
  source  = "app.terraform.io/sapience-analytics/resourcegroup/azurerm"
  version = "1.0.3"

  environment     = var.environment
}

# -------------------------------------------------------------------------------
# Storage Account - Blob Storage
# -------------------------------------------------------------------------------

module "blobstorage" {
  source  = "app.terraform.io/sapience-analytics/storageaccount/azurerm"
  version = "1.0.6"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
  name            = "vue${var.environment${var.location}"
}

# -------------------------------------------------------------------------------
# Blob Containers
# -------------------------------------------------------------------------------

module "leaf_uploads" {
  source  = "app.terraform.io/sapience-analytics/storagecontainer/azurerm"
  version = "1.0.0"

  name                 = "leaf_uploads"
  environment          = var.environment
  resource_group       = module.resourcegroup.name
  storage_account_name = module.blobstorage.name
  access_type          = "blob"
}


module "leaf_downloads" {
  source  = "app.terraform.io/sapience-analytics/storagecontainer/azurerm"
  version = "1.0.0"

  name                 = "leaf_downloads"
  environment          = var.environment
  resource_group       = module.resourcegroup.name
  storage_account_name = module.blobstorage.name
  access_type          = "blob"
}

# -------------------------------------------------------------------------------
# Storage Account - Data Lake
# -------------------------------------------------------------------------------

module "datalake" {
  source  = "app.terraform.io/sapience-analytics/storageaccount/azurerm"
  version = "1.0.6"

  environment      = var.environment
  resource_group   = module.resourcegroup.name
  name             = "vuedl${var.environment${var.location}"
  replication_type = "LRS"
}

# -------------------------------------------------------------------------------
# Datalake Private Containers
# -------------------------------------------------------------------------------

module "datalake_container" {
  source  = "app.terraform.io/sapience-analytics/storagecontainer/azurerm"
  version = "1.0.0"

  name                 = "vue-adls"
  environment          = var.environment
  resource_group       = module.resourcegroup.name
  storage_account_name = module.datalake.name
  access_type          = "private"
}

# -------------------------------------------------------------------------------
# Virtual Network
# -------------------------------------------------------------------------------

module "network" {
  source  = "app.terraform.io/sapience-analytics/network/azurerm"
  version = "1.0.2"

  environment                                          = var.environment
  resource_group                                       = module.resourcegroup.name
  virtual_network_address_space                        = [ "10.1.0.0/16" ]
  subnet_default_address_prefix                        = "10.1.0.0/20"
  subnet_application_address_prefix                    = "10.1.16.0/20"
  subnet_data_address_prefix                           = "10.1.32.0/20"
  subnet_aks_stateless_default_pool_address_prefix     = "10.1.48.0/20"
  subnet_aks_stateful_default_pool_address_prefix      = "10.1.64.0/20"
  subnet_bastion_address_prefix                        = "10.1.240.0/20"
}

# -------------------------------------------------------------------------------
# Log Analytics Workspace
# -------------------------------------------------------------------------------

module "loganalyticsworkspace" {
  source  = "app.terraform.io/sapience-analytics/loganalyticsworkspace/azurerm"
  version = "1.0.1"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
}

# -------------------------------------------------------------------------------
# Kubernetes - Stateless - Black
# -------------------------------------------------------------------------------

module "kubernetes-stateless-black" {
  source  = "app.terraform.io/sapience-analytics/kubernetes/azurerm"
  version = "1.0.4"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
  client_id       = var.client_id
  client_secret   = var.client_secret
  vnet_subnet_id  = module.network.aks_stateless_default_pool_subnet_id
}

# -------------------------------------------------------------------------------
# Kubernetes - Stateful - Black
# -------------------------------------------------------------------------------

module "kubernetes-stateful-black" {

  source  = "app.terraform.io/sapience-analytics/kubernetes/azurerm"
  version = "1.0.4"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
  client_id       = var.client_id
  client_secret   = var.client_secret
  vnet_subnet_id  = module.network.aks_stateful_default_pool_subnet_id
  state           = "stateful"
} 

# -------------------------------------------------------------------------------
# Resource Group
# -------------------------------------------------------------------------------

module "servicebus" {
  source  = "app.terraform.io/sapience-analytics/servicebus/azurerm"
  version = "1.0.0"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
}