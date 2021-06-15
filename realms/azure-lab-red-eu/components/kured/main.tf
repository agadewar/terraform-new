terraform {
  backend "azurerm" {
    key = "red/kured.tfstate"
  }
}

provider "helm" {
  #version = "0.10.4"
  kubernetes {
    config_path = local.config_path
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  #service_account = "tiller"
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Kured"
    },
  )
}

resource "helm_release" "kured" {
  name      = "kured"
  namespace = "kube-system"
  chart     = "stable/kured"
}
