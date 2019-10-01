###############################################
# SUMMARY
# - Virtual Network            (10.106.0.0/16)
#     - prod-web-app-firewall  (10.106.40.0/22)
#     - prod-default           (10.106.44.0/22)
#     - prod-application       (10.106.48.0/22)
#     - prod-data              (10.106.52.0/22)
###############################################

#########################################
# TERRAFROM REMOTE STATE - (READ / WRITE)
#########################################
terraform {
  backend "azurerm" {
    key = "network.tfstate"
  }
}

#########################################
# AZURE PLUGIN
#########################################
provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

#########################################
# TERRAFORM REMOTE STATE - (READ-ONLY)
#########################################
data "terraform_remote_state" "network_realm" {
  backend = "azurerm"
  config  = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "network.tfstate"
  }
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

####################
# ENV-GATEWAY SUBNET
####################
resource "azurerm_subnet" "env-web-app-firewall" {
  name                 = "${var.environment}-web-app-firewall"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.virtual_network_env_web-app-firewall
}

####################
# ENV-DEFAULT SUBNET
####################
resource "azurerm_subnet" "env-default" {
  name                 = "${var.environment}-default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.virtual_network_env_default
}

########################
# ENV-APPLICATION SUBNET
########################
resource "azurerm_subnet" "env-application" {
  name                 = "${var.environment}-application"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.virtual_network_env_application
}

#################
# ENV-DATA SUBNET
#################
resource "azurerm_subnet" "env-data" {
  name                 = "${var.environment}-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network_realm.outputs.realm_network_name
  address_prefix       = var.virtual_network_env_data
}

