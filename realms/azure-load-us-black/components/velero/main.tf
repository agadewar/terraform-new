terraform {
  backend "azurerm" {
    key = "velero/kured.tfstate"
  }
}

provider "helm" {
  #version = "0.10.4"
  kubernetes {
    config_path = local.config_path
  }

}

locals {
  config_path = "../kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "velero"
    },
  )
}

resource "helm_release" "velero" {
  name      = "velero"
  namespace = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart     = "velero"

set {
    name  = "credentials.secretContents.cloud"
    value = "azure"
  }

set {
    name  = "configuration.provider"
    value = "azure"
  }

set {
    name  = "configuration"
    value = "azure"
  }

set {
    name  = "configuration.backupStorageLocation"
    value = "azure"
  }

 set {
    name  = "configuration.backupStorageLocation.bucket"
    value = "velero"
  } 

set {
    name  = "configuration.backupStorageLocation.config.resourceGroup"
    value = "load-us"
  }

set {
    name  = "configuration.backupStorageLocation.config.storageAccount"
    value = "sapienceveleroloadus"
    }

set {
    name  = "snapshotsEnable"
    value = true
  }

set {
    name  = "deployRestic"
    value = true
  }

set {
    name  = "configuration.volumeSnapshotLocation.name"
    value = "azure"
  }

set {
    name  = "image.repository"
    value = "velero/velero"
  }

set {
    name  = "image.pullPolicy"
    value = "Always"
  }

set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-microsoft-azure"
  }  

set {
    name  = "initContainers[0].image"
    value = "velero/velero-plugin-for-microsoft-azure:master"
  } 

set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  } 

set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  } 

}