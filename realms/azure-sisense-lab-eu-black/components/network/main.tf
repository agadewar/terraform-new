terraform {
  backend "azurerm" {
    key = "network.tfstate"
  }
}

provider "azurerm" {
  version = "2.0.0"
  features {}
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

locals {
  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Network"
    },
  )
}

resource "azurerm_virtual_network" "realm" {
  name                = "${var.resource_group_name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space       = var.virtual_network_address_space
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_default
  service_endpoints    = var.subnet_service_endpoints
}

# resource "azurerm_subnet" "demo-default" {
#   name                 = "demo-default"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_demo-default
#   service_endpoints    = var.subnet_service_endpoints
# }

# resource "azurerm_subnet" "demo-application" {
#   name                 = "demo-application"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_demo-application
#   service_endpoints    = var.subnet_service_endpoints
# }

# resource "azurerm_subnet" "demo-data" {
#   name                 = "demo-data"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_demo-data
#   service_endpoints    = var.subnet_service_endpoints
# }

resource "azurerm_subnet" "aks-pool" {
  name                 = "aks-pool"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool
  service_endpoints    = var.subnet_service_endpoints
  lifecycle { 
    #ignore_changes = [ route_table_id ]
  }
}

resource "azurerm_subnet" "netapp" {
  name                 = "netapp"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_netapp
  delegation { 
    name               = "netapp" 
    service_delegation {
      name             = "Microsoft.Netapp/volumes"
      actions          = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]

    }
  }
}


resource "azurerm_subnet" "aks_northeu_sisense" {

  name                 = "aks-northeu-sisense"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks_northeu_sisense

}

