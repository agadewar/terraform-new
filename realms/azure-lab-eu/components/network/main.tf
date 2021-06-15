terraform {
  backend "azurerm" {
    key = "network.tfstate"
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
      "Component" = "Network"
    },
  )
}

# VISUAL SUBNET CALCULATOR - 
# http://davidc.net/sites/default/subnets/subnets.html?network=10.104.0.0&mask=16&division=59.f39770c13e13451
resource "azurerm_virtual_network" "realm" {
  name                = var.resource_group_name
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

resource "azurerm_subnet" "aks-pool" {
  name                 = "aks-pool"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "aks_eastus_sisense_netapp" {
  name                 = "aks-eastus-sisense-netapp"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks_eastus_sisense_netapp
  # delegation { 
  #   name               = "netapp" 
  #   service_delegation {
  #     name             = "Microsoft.Netapp/volumes"
  #     actions          = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
  #   }
  # }
}

resource "azurerm_subnet" "aks_eastus_sisense" {
  name                 = "aks-eastus-sisense"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks_eastus_sisense
  service_endpoints    = var.subnet_service_endpoints
}

# resource "azurerm_subnet" "aks-pool01" {
#   name                 = "aks-pool01"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_aks-pool01
#   service_endpoints    = var.subnet_service_endpoints
#   route_table_id       = "/subscriptions/b78a61e7-f2ed-4cb0-8f48-6548408935e9/resourceGroups/MC_lab-us_lab-us-black_eastus/providers/Microsoft.Network/routeTables/aks-agentpool-34839511-routetable"
# }

/* resource "azurerm_subnet" "aks-pool02" {
  name                 = "aks-pool02"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool02
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "aks-pool03" {
  name                 = "aks-pool03"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool03
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "aks-pool04" {
  name                 = "aks-pool04"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool04
  service_endpoints    = var.subnet_service_endpoints
}
 */