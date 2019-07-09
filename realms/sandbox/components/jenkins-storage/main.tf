terraform {
  backend "azurerm" {
    key = "jenkins-storage.tfstate"
  }
}

provider "azurerm" {
  version         = "1.30.1"
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}


data "terraform_remote_state" "storage_account" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = "realm-${var.realm}"
    key                  = "storage-account.tfstate"
  }
}

locals {
  realm = var.realm

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Jenkins Storage"
    },
  )
}

resource "azurerm_managed_disk" "jenkins_home" {
  name                 = "jenkins-home-${var.realm}"
  location             = var.resource_group_location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = merge(local.common_tags, {})

  lifecycle {
    prevent_destroy = "true"
  }
}

// STORAGE ACCOUNT IN PLACE OF MANAGED DISK TO ALLOW READ/WRITE-MANY
// SET UP WITH TERRAFORM KUBERNETES_SECRET
// 7/5/19 - Don't need this storage account created. See storage_account_name in azurerm_storage_share.maven_repo.
// resource "azurerm_storage_account" "maven_repo" {
//   name                     = "mavenrepo${var.realm}"
//   resource_group_name      = var.resource_group_name
//   location                 = var.resource_group_location
//   account_tier             = "Standard"
//   account_replication_type = "LRS"
//   account_kind             = "StorageV2"

//   tags = merge(local.common_tags, {})
// }

resource "azurerm_storage_share" "maven_repo" {
  name = "maven-repo"

  resource_group_name = var.resource_group_name

  // storage_account_name = "${azurerm_storage_account.maven_repo.name}"
  storage_account_name = data.terraform_remote_state.storage_account.outputs.storage_account_name

  quota = 20
}

