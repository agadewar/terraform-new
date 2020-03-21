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

provider "null" {

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
# - Internal Private DNS Zone
# - Application Insights
# - SQL Server / Databases / Firewall Rules
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
  name            = "vue${var.environment}${var.location}"
}

# -------------------------------------------------------------------------------
# Blob Containers
# -------------------------------------------------------------------------------

module "leaf_uploads" {
  source  = "app.terraform.io/sapience-analytics/storagecontainer/azurerm"
  version = "1.0.0"

  name                 = "leaf-uploads"
  environment          = var.environment
  resource_group       = module.resourcegroup.name
  storage_account_name = module.blobstorage.name
  access_type          = "blob"
}


module "leaf_downloads" {
  source  = "app.terraform.io/sapience-analytics/storagecontainer/azurerm"
  version = "1.0.0"

  name                 = "leaf-downloads"
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
  name             = "vuedl${var.environment}${var.location}"
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
# Kubernetes Black Cluster
# -------------------------------------------------------------------------------

module "kubernetes" {
  source  = "app.terraform.io/sapience-analytics/kubernetes/azurerm"
  version = "1.0.5"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
  client_id       = var.client_id
  client_secret   = var.client_secret
  vnet_subnet_id  = module.network.aks_stateless_default_pool_subnet_id
}

# -------------------------------------------------------------------------------
# Service Bus
# -------------------------------------------------------------------------------

module "servicebus" {
  source  = "app.terraform.io/sapience-analytics/servicebus/azurerm"
  version = "1.0.0"

  environment     = var.environment
  resource_group  = module.resourcegroup.name
}

# -------------------------------------------------------------------------------
# Internal Private DNS Zone
# -------------------------------------------------------------------------------

module "privatednszone" {
  source  = "app.terraform.io/sapience-analytics/privatednszone/azurerm"
  version = "1.0.1"

  environment        = var.environment
  resource_group     = module.resourcegroup.name
  virtual_network_id = module.network.virtual_network_id
}

# -------------------------------------------------------------------------------
# Application Insights
# -------------------------------------------------------------------------------

module "app-insights" {
  source  = "app.terraform.io/sapience-analytics/appinsights/azurerm"
  version = "1.0.1"

  environment        = var.environment
  resource_group     = module.resourcegroup.name
}

# -------------------------------------------------------------------------------
# SQL Server / Databases / Firewall Rules
# -------------------------------------------------------------------------------

module "sql" {
  source  = "app.terraform.io/sapience-analytics/sql/azurerm"
  version = "1.0.2"

  environment               = var.environment
  resource_group            = module.resourcegroup.name
  sql_server_admin_password = var.sql_server_admin_password
}

# -------------------------------------------------------------------------------
# MySql Server / Databases / Firewall Rules
# -------------------------------------------------------------------------------

module "mysql" {
  source  = "app.terraform.io/sapience-analytics/mysql/azurerm"
  version = "1.0.5"

  environment                 = var.environment
  resource_group              = module.resourcegroup.name
  mysql_server_admin_password = var.sql_server_admin_password
}

# -------------------------------------------------------------------------------
# Cosmos DB instances
# -------------------------------------------------------------------------------

module "cosmosdb" {
  source  = "app.terraform.io/sapience-analytics/cosmosdb/azurerm"
  version = "1.1.0"

  environment               = var.environment
  resource_group            = module.resourcegroup.name
}

resource "null_resource" "kubeconfig" {

  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "tools/az login --service-principal -u ${application_uri} -p ${application_password} --tenant ${tenant_id}"
  }
}