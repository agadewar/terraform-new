terraform {
  backend "azurerm" {
    key = "jenkins-storage.tfstate"
  }
}

provider "azurerm" {
  version = "1.35.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

locals {
  realm = "${var.realm}"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Jenkins Storage"
    )
  )}"
}

data "terraform_remote_state" "storage_account" {
  backend = "azurerm"

  config = {
    access_key            = var.realm_backend_access_key
    storage_account_name  = var.realm_backend_storage_account_name
	  container_name        = var.realm_backend_container_name
    key                   = "storage-account.tfstate"
  }
}

resource "azurerm_managed_disk" "jenkins_home" {
  name                 = "jenkins-home"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = "${merge(
    local.common_tags
  )}"
  
  # lifecycle{
  #   prevent_destroy = "true"
  # }
}


# // STORAGE ACCOUNT IN PLACE OF MANAGED DISK TO ALLOW READ/WRITE-MANY
# // SET UP WITH TERRAFORM KUBERNETES_SECRET
# resource "azurerm_storage_account" "maven_repo" {
#   name                      = "mavenrepo${var.realm}"
#   resource_group_name       = "${var.resource_group_name}"
#   location                  = "${var.resource_group_location}"
#   account_tier              = "Standard"
#   account_replication_type  = "LRS"
#   account_kind              = "StorageV2"

#   tags = "${merge(
#     local.common_tags
#   )}"
# }

# resource "azurerm_storage_share" "jenkins_home" {
#   name = "jenkins-home"

#   resource_group_name  = var.resource_group_name
#   storage_account_name = data.terraform_remote_state.storage_account.outputs.storage_account_file_name

#   quota = 100

#   lifecycle {
#     prevent_destroy = true
#   }
# }

resource "azurerm_storage_share" "maven_repo" {
  name = "jenkins-maven-repo"

  resource_group_name  = var.resource_group_name
  #storage_account_name = "${azurerm_storage_account.maven_repo.name}"
  storage_account_name = data.terraform_remote_state.storage_account.outputs.storage_account_file_name

  quota = 100
}