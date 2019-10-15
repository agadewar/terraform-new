terraform {
  backend "azurerm" {
    key = "container-registry.tfstate"
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
      "Component" = "Container Registry"
    },
  )
}

resource "azurerm_container_registry" "acr" {
  name                = "sapienceanalytics"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
  admin_enabled       = true
}