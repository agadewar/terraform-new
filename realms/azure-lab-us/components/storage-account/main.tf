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

resource "azurerm_storage_container" "leaf_uploads" {
  name                  = "leaf-uploads"
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.storage_account.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_container" "leaf_downloads" {
  name                  = "leaf-downloads"
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.storage_account.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_account" "bulk_upload_dev" {
  name                      = "saplabusbudev"
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

resource "azurerm_storage_container" "sapience-upload-dev" {
  name                  = "sapience-upload"
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.bulk_upload_dev.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_account" "bulk_upload_demo" {
  name                      = "saplabusbudemo"
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

resource "azurerm_storage_container" "sapience-upload-demo" {
  name                  = "sapience-upload"
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.bulk_upload_demo.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_account" "bulk_upload_qa" {
  name                      = "saplabusbuqa"
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

resource "azurerm_storage_container" "sapience-upload-qa" {
  name                  = "sapience-upload"
  resource_group_name   = var.resource_group_name
  storage_account_name  = "${azurerm_storage_account.bulk_upload_qa.name}"
  container_access_type = "blob"
}

resource "azurerm_storage_account" "talend_storage_account" {
  name                      = "talend${replace(var.realm, "-", "")}dev"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "ZRS"
  enable_https_traffic_only = "true"

  tags = merge(local.common_tags)

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_storage_container" "talend_storage_account" {
  name                  = "talend-${replace(var.realm, "-", "")}-dev"
  resource_group_name   = var.resource_group_name
  storage_account_name  = azurerm_storage_account.talend_storage_account.name
  container_access_type = "blob"
}

resource "azurerm_storage_account" "talend_storage_account_qa" {
  name                      = "talend${replace(var.realm, "-", "")}qa"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "ZRS"
  enable_https_traffic_only = "true"

  tags = merge(local.common_tags)

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_storage_container" "talend_storage_container_qa" {
  name                  = "talend-${replace(var.realm, "-", "")}-qa"
  resource_group_name   = var.resource_group_name
  storage_account_name  = azurerm_storage_account.talend_storage_account_qa.name
  container_access_type = "blob"
}

resource "azurerm_storage_account" "talend_storage_account_demo" {
  name                      = "talend${replace(var.realm, "-", "")}demo"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "ZRS"
  enable_https_traffic_only = "true"

  tags = merge(local.common_tags)

  lifecycle {
    prevent_destroy = "true"
  }
}

resource "azurerm_storage_container" "talend_storage_container_demo" {
  name                  = "talend-${replace(var.realm, "-", "")}-demo"
  resource_group_name   = var.resource_group_name
  storage_account_name  = azurerm_storage_account.talend_storage_account_demo.name
  container_access_type = "blob"
}