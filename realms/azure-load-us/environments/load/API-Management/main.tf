terraform {
    backend "azurerm" {
      key = "api-management.tfstate"
    }
  }
  
  provider "azurerm" {
    version         = "1.31.0"
    subscription_id = var.subscription_id
  }

#locals {
#  common_tags = merge(
#    var.realm_common_tags,
#    var.environment_common_tags,
#    {
#      "Component" = "api-management"
#    },
#  )
#}