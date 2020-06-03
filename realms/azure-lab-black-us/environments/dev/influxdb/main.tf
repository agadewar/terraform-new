terraform {
  backend "azurerm" {
    key = "black/influxdb.tfstate"
  }

  required_providers {
    helm = "= 1.0.0"
  }
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  # # #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  # service_account = "tiller"
}

provider "kubernetes" {
  config_path = local.config_path
}

data "terraform_remote_state" "storage" {
  backend = "azurerm"

  config = {
    access_key           = "${var.realm_backend_access_key}"
    storage_account_name = "${var.realm_backend_storage_account_name}"
	  container_name       = "${var.realm_backend_container_name}"
    key                  = "black/storage.tfstate"
  }
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
  name      = "influxdb"
  namespace = var.environment
  chart     = "stable/influxdb"

  set {
    name  = "persistence.enabled"
    value = "true"
  }

  set {
    name  = "persistence.storageClass"
    value = data.terraform_remote_state.storage.outputs.azure_file_storage_class_name
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
    name  = "setDefaultUser.user.password"
    value = var.influxdb_password
  }

  set {
    name  = "resources.requests.cpu"
    value = "1500m"
  }

  set {
    name  = "resources.requests.memory"
    value = "3072Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "4000m"
  }

  set {
    name  = "resources.limits.memory"
    value = "4096Mi"
  }

  set {
    name  = "livenessProbe.initialDelaySeconds"
    value = "3600"
  }
}
