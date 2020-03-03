terraform {
  backend "azurerm" {
    key = "acme.tfstate"
  }
}

provider "azurerm" {
  version         = "1.35.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

locals {
  realm = var.realm

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Acme"
    },
  )
}

resource "azurerm_storage_account" "acme" {
  name                      = "sapienceacmecerts"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = "true"

  tags = merge(local.common_tags)

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_storage_container" "poshacme" {
  name                  = "poshacme"
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.acme.name}"
  container_access_type = "blob"
}


resource "azurerm_key_vault" "acmecerts" {
  name                        = "sapienceacmecerts"
  location                    = var.resource_group_location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = "9c5c9da2-8ba9-4f91-8fa6-2c4382395477"

  sku_name = "standard"

  tags = merge(local.common_tags)
}