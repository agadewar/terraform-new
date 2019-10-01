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
    key = "network.tfstate"
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

#################
# VIRTUAL NETWORK
#################
resource "azurerm_virtual_network" "realm" {
  name                = "${var.resource_group_name}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = var.virtual_network_address_space
  
  tags = "${merge(
      local.common_tags
  )}"
}

################
# DEFAULT SUBNET
################
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.virtual_network_default_subnet
  service_endpoints    = var.virtual_network_subnet_service_endpoints
  
}

#######################
# MANAGED-DOMAIN SUBNET
#######################
resource "azurerm_subnet" "managed_domain" {
  name                 = "domain"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.virtual_network_domain_subnet
  service_endpoints    = var.virtual_network_subnet_service_endpoints
  
}
