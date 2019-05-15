terraform {
  backend "azurerm" {
    key = "sapience.realm.sandbox.jenkins-storage.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
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

resource "azurerm_managed_disk" "jenkins_home" {
  name                 = "jenkins-home-${var.realm}"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
  
  lifecycle{
    prevent_destroy = "true"
  }
}

# // DELETE MAVEN MANAGED DISK IF THE STORAGE ACCOUNT IS WORKING
# resource "azurerm_managed_disk" "maven_repo" {
#   name                 = "maven-repo-${var.realm}"
#   location             = "${var.resource_group_location}"
#   resource_group_name  = "${var.resource_group_name}"
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "20"

#   tags = "${merge(
#     local.common_tags,
#     map()
#   )}"
  
#   lifecycle{
#     prevent_destroy = "true"
#   }
# }

// STORAGE ACCOUNT IN PLACE OF MANAGED DISK TO ALLOW READ/WRITE-MANY
// SET UP WITH TERRAFORM KUBERNETES_SECRET
resource "azurerm_storage_account" "maven_repo" {
  name                      = "mavenrepo${var.realm}"
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.resource_group_location}"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "azurerm_storage_share" "maven_repo" {
  name = "maven-repo"

  resource_group_name       = "${var.resource_group_name}"
  storage_account_name = "${azurerm_storage_account.maven_repo.name}"

  quota = 20
}