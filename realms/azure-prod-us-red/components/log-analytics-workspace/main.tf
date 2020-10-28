terraform {
  backend "azurerm" {
    key = "red/log-analytics-workspace.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

locals {
  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Log Analyics Workspace"
    },
  )
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = "sapience-${var.realm}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}