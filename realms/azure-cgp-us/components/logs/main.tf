#######################################
# SUMMARY
# - Virtual Network (10.106.0.0/16)
#     - Default Subnet  (10.106.0.0/22)
#     - Domain Subnet   (10.106.4.0/22)
#######################################

#########################################
# TERRAFROM REMOTE STATE - (READ / WRITE)
#########################################
terraform {
  backend "azurerm" {
    key = "logs.tfstate"
  }
}

##############
# AZURE PLUGIN
##############
provider "azurerm" {
  version         = "1.31.0"
  
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

#################
# LOCAL VARIABLES
#################
locals {
  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Network"
    },
  )
}

#########################
# Log Analytics Workspace
#########################
resource "azurerm_log_analytics_workspace" "cgp-us" {
  name                = var.resource_group_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 365
}

