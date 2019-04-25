terraform {
  backend "azurerm" {
    key = "sapience.realm.global.jenkins-storage.terraform.tfstate"
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

resource "azurerm_managed_disk" "maven_repo" {
  name                 = "maven-repo-${var.realm}"
  location             = "${var.resource_group_location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
  
  lifecycle{
    prevent_destroy = "true"
  }
}