terraform {
  backend "azurerm" {
    key = "cert-manager.tfstate"
  }
}

# provider "azurerm" {
#   version = "1.20.0"
#   subscription_id = "${var.subscription_id}"
# }

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

provider "kubernetes" {
  config_path = "${local.config_path}"
}

# data "terraform_remote_state" "kubernetes" {
#   backend = "azurerm"

#   config {
#     access_key           = "${var.backend_access_key}"
#     storage_account_name = "${var.backend_storage_account_name}"
# 	  container_name       = "realm-${var.realm}"
#     key                  = "kubernetes.tfstate"
#   }
# }

locals {
  namespace = "cert-manager"

  config_path = "../kubernetes/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Cert Manager"
    )
  )}"
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
  }
}

# See: https://hub.helm.sh/charts/jetstack/cert-manager/v0.6.0
resource "helm_release" "cert_manager" {
  depends_on = [ "kubernetes_namespace.namespace" ]

  name       = "cert-manager"
  namespace  = "${kubernetes_namespace.namespace.metadata.0.name}"
  chart      = "cert-manager"
  version    = "v0.6.0"
  repository = "${data.helm_repository.jetstack.metadata.0.name}"
  
  set {
    name  = "webhook.enabled"
    value = "false"
  }

  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "resources.requests.memory"
    value = "32Mi"
  }
}
