terraform {
  backend "azurerm" {
    key = "black/influxdb.tfstate"
  }

  required_providers {
    helm = "= 0.10.4"
  }
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  # #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

provider "kubernetes" {
  config_path = local.config_path
}

locals {
  config_path = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "InfluxDB"
    },
  )
}

resource "helm_release" "influxdb" {
  name      = "influxdb-${var.environment}"
  namespace = var.environment
  chart     = "stable/influxdb"

  timeout = 900

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.storageClass"
    value = "${kubernetes_storage_class.influxdb.metadata.0.name}"
  }

  set {
    name  = "persistence.accessMode"
    value = "ReadWriteMany"
  }

  set {
    name  = "persistence.size"
    value = "200Gi"
  }

  set {
    name  = "setDefaultUser.enabled"
    value = "true"
  }

  set {
    name  = "setDefaultUser.user.password"    // TODO: set default password in tfvars
    value = "J83mk5a59yUm"
  }

  set {
    name  = "resources.requests.cpu"
    value = "1500m"
  }

  set {
    name  = "resources.requests.memory"
    value = "1024Mi"
  }
}

// See: https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv
resource "kubernetes_storage_class" "influxdb" {
  metadata {
    name = "influxdb"
  }

  storage_provisioner = "kubernetes.io/azure-file"
  reclaim_policy      = "Retain"

  parameters = {
    skuName = "Standard_LRS"
  }

  mount_options = [ "dir_mode=0777", "file_mode=0700", "uid=1000", "gid=1000", "mfsymlinks", "nobrl", "cache=none" ]
}
