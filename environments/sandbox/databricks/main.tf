terraform {
  backend "azurerm" {
    key = "sapience.environment.sandbox.databricks.terraform.tfstate"
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
      "Component", "Databricks"
    )
  )}"
}

resource "azurerm_databricks_workspace" "databricks" {
  name                = "databricks-${var.environment}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.resource_group_location}"
  sku                 = "premium"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}