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
  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Jenkins Storage"
    )
  )}"
}

resource "azurerm_managed_disk" "jenkins_home" {
  name                 = "jenkins-home"
  location             = "eastus"
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

resource "azurerm_managed_disk" "maven_repo" {
  name                 = "maven-repo"
  location             = "eastus"
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