terraform {
  backend "azurerm" {
    key = "sapience.environment.dev.functions.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

locals {
  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Functions"
    )
  )}"
}

resource "azurerm_storage_account" "sapience_functions" {
  name                     = "sapiencefunctions${var.environment}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "eastus2"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

# resource "azurerm_storage_account" "azure_web_jobs_storage" {
#   name                     = "sapiencewebjobs${var.environment}"
#   resource_group_name      = "${var.resource_group_name}"
#   location                 = "eastus2"
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = "${merge(
#     local.common_tags,
#     map()
#   )}"
# }

resource "azurerm_app_service_plan" "service_plan" {
  name                = "azure-functions-service-plan-${var.environment}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                      = "azure-functions-app-${var.environment}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
  app_service_plan_id       = "${azurerm_app_service_plan.service_plan.id}"
  storage_connection_string = "${azurerm_storage_account.sapience_functions.primary_connection_string}"
  version = "~2"
}