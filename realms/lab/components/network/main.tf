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


# OLD NETWORK.  DELETE AFTER SAPIENCE REMOVES THE SISENSE VM.
resource "azurerm_virtual_network" "default" {
  name                = "${var.resource_group_name}-vnet"
  location            = var.resource_group_location
  address_space       = var.virtual_network_address_space_old
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefix       = var.subnet_address_prefix
  service_endpoints    = var.subnet_service_endpoints
}


# NEW NETWORK
resource "azurerm_virtual_network" "realm" {
  name                = "${var.resource_group_name}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  address_space       = var.virtual_network_address_space
}

// BEFORE APPLYING THIS SUBNET, NEED TO DESTROY DEFAULT SUBNET FROM THE OLD NETWORK FIRST
// resource "azurerm_subnet" "default" {
//   name                 = "default"
//   resource_group_name  = var.resource_group_name
//   virtual_network_name = azurerm_virtual_network.realm.name
//   address_prefix       = var.subnet_address_prefix_default
//   service_endpoints    = var.subnet_service_endpoints
// }

resource "azurerm_subnet" "dev-default" {
  name                 = "dev-default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_dev-default
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "dev-application" {
  name                 = "dev-application"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_dev-application
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "dev-data" {
  name                 = "dev-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_dev-data
  service_endpoints    = var.subnet_service_endpoints
}

# resource "azurerm_subnet" "qa-default" {
#   name                 = "qa-default"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_qa-default
#   service_endpoints    = var.subnet_service_endpoints
# }

# resource "azurerm_subnet" "qa-application" {
#   name                 = "qa-application"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_qa-application
#   service_endpoints    = var.subnet_service_endpoints
# }

# resource "azurerm_subnet" "qa-data" {
#   name                 = "qa-data"
#   resource_group_name  = var.resource_group_name
#   virtual_network_name = azurerm_virtual_network.realm.name
#   address_prefix       = var.subnet_address_prefix_qa-data
#   service_endpoints    = var.subnet_service_endpoints
# }

resource "azurerm_subnet" "aks-pool04" {
  name                 = "aks-pool04"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool04
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "aks-pool03" {
  name                 = "aks-pool03"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool03
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "aks-pool02" {
  name                 = "aks-pool02"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool02
  service_endpoints    = var.subnet_service_endpoints
}

resource "azurerm_subnet" "aks-pool01" {
  name                 = "aks-pool01"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.realm.name
  address_prefix       = var.subnet_address_prefix_aks-pool01
  service_endpoints    = var.subnet_service_endpoints
}

