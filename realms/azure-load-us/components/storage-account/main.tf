terraform {
  backend "azurerm" {
    key = "storage-account.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"

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
      "Component" = "Storage Account"
    },
  )
}

resource "azurerm_storage_account" "storage_account" {
  name                      = "sapience${replace(var.realm, "-", "")}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_tier              = "Standard"
  account_replication_type  = "ZRS"
  account_kind              = "StorageV2"
  enable_https_traffic_only = "true"

  tags = merge(local.common_tags)

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_storage_account" "talend_storage_account" {
  name                     = "talend${replace(var.realm, "-", "")}"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_kind              = "StorageV2"
  account_replication_type = "ZRS"
  enable_https_traffic_only = "true"

  tags = merge(local.common_tags)

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_storage_container" "talend_storage_account" {
  name                  = "talend-${replace(var.realm, "-", "")}-load"
  resource_group_name      = var.resource_group_name
  storage_account_name  = azurerm_storage_account.talend_storage_account.name
  container_access_type = "Blob"
} 