terraform {
  backend "azurerm" {
    key = "storage.tfstate"
  }
}

provider "kubernetes" {
  config_path = local.config_path
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Storage"
    },
  )
}

// See: https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv
resource "kubernetes_storage_class" "azure_file" {
  metadata {
    name = "azure-file"
  }

  storage_provisioner = "kubernetes.io/azure-file"
  reclaim_policy      = "Retain"

  parameters = {
    skuName = "Standard_LRS"
  }

  mount_options = [ "dir_mode=0777", "file_mode=0700", "uid=1000", "gid=1000", "mfsymlinks", "nobrl", "cache=none" ]
}