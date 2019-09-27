terraform {
  backend "azurerm" {
    key = "app-gateway.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = var.env_backend_container_name
    key                  = "network.tfstate"
  }
}

data "terraform_remote_state" "vm" {
  backend = "azurerm"
   
  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = var.env_backend_container_name
    key                  = "vm.tfstate"
  }

}

locals {
  resource_name = "sapience-${var.realm}-${var.environment}"
}

locals {
  common_tags = merge(
    var.environment_common_tags,
    {
      Component = "VM"
    },
  )
}

# CREATE PUBLIC IP AND ISSUE TO APP GATEWAY BELOW
resource "azurerm_public_ip" "cgp_appgateway" {
  name                = "${local.resource_name}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
  sku                 = "Standard"

}

# FIND SKU (REST API) - https://github.com/Azure/azure-rest-api-specs/blob/master/specification/network/resource-manager/Microsoft.Network/stable/2018-12-01/applicationGateway.json
resource "azurerm_application_gateway" "cgp" {
  name                = "${local.resource_name}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  enable_http2        = "true"

  sku {
    name     = "WAF_V2"
    tier     = "WAF_V2"
  }

  gateway_ip_configuration {
    name      = "${local.resource_name}"
    subnet_id = data.terraform_remote_state.network.outputs.env-gateway_subnet_id
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 5
  }

  frontend_port {
    name = "${local.resource_name}"
    port = 80
  }

  frontend_ip_configuration {
    name                          = "${local.resource_name}"
    public_ip_address_id          = "${azurerm_public_ip.cgp_appgateway.id}"
  }

  backend_address_pool {
    name  = "${local.resource_name}"
  }

  backend_http_settings {
    name                  = "${local.resource_name}"
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "sapience-app"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 120
  }

  http_listener {
    name                           = "${local.resource_name}"
    frontend_ip_configuration_name = "${local.resource_name}"
    frontend_port_name             = "${local.resource_name}"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${local.resource_name}"
    rule_type                  = "Basic"
    http_listener_name         = "${local.resource_name}"
    backend_address_pool_name  = "${local.resource_name}"
    backend_http_settings_name = "${local.resource_name}"
  }

  waf_configuration {
    enabled       =    "true"
    firewall_mode =    "Detection"
    rule_set_type =    "OWASP"
    rule_set_version = "3.0"
  }
}

# CONNECT VIRTUAL MACHINE TO BACKEND SERVER POOL
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "cgp" {
    network_interface_id    = data.terraform_remote_state.vm.outputs.network_interface_sapience_cgp_001
    ip_configuration_name   = data.terraform_remote_state.vm.outputs.ip_configuration_sapience_cgp_001[0].name
    backend_address_pool_id = azurerm_application_gateway.cgp.backend_address_pool[0].id
}