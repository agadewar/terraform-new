terraform {
  backend "azurerm" {
    key = "sapience.realm.sandbox.openfaas.terraform.tfstate"
  }
}

# See: https://github.com/openfaas/faas-netes/blob/master/chart/openfaas/README.md
# See: https://docs.microsoft.com/en-us/azure/aks/openfaas

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

provider "kubernetes" {
  version = "1.5.0"
  config_path = "${local.config_path}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

locals {
  namespace = "openfaas"

  config_path = "../../../realms/${var.realm}/kubernetes/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "OpenFaaS"
    )
  )}"
}

resource "kubernetes_namespace" "openfaas" {
  metadata {
    name = "${var.environment}-${local.namespace}"
  }
}

resource "kubernetes_namespace" "openfaas-fn" {
  metadata {
    name = "${var.environment}-${local.namespace}-fn"
  }
}

resource "kubernetes_resource_quota" "resource_quota" {
  metadata {
    name      = "resource-quota-${local.namespace}"
    namespace = "${kubernetes_namespace.openfaas.metadata.0.name}"
  }

  spec {
    hard {
      requests.memory = "7Gi"
      requests.cpu = "2"
    }
  }
}

resource "kubernetes_limit_range" "openfaas" {
  metadata {
      name      = "limit-range-${local.namespace}"
      namespace = "${kubernetes_namespace.openfaas.metadata.0.name}"
  }
  spec {
    limit {
      type = "Container"
      default {
        memory = "50M"
        cpu = "100m"
      }
    }
  }
}

resource "kubernetes_secret" "basic_auth" {
  metadata {
    name      = "basic-auth"
    namespace = "${kubernetes_namespace.openfaas.metadata.0.name}"
  }

  data {
    "basic-auth-user"     = "admin"
    "basic-auth-password" = "${var.openfaas_admin_password}"
  }

  type = "Opaque"
}

data "helm_repository" "openfaas_charts" {
    name = "openfaas"
    url  = "https://openfaas.github.io/faas-netes/"
}

resource "helm_release" "openfaas" {
    depends_on = [ "kubernetes_limit_range.openfaas" ]

    name       = "openfaas"
    namespace  = "${kubernetes_namespace.openfaas.metadata.0.name}"
    repository = "${data.helm_repository.openfaas_charts.name}"
    chart      = "openfaas/openfaas"

    set {
      name  = "basic_auth"
      value = "true"
    }

    set {
      name  = "functionNamespace"
      value = "${kubernetes_namespace.openfaas-fn.metadata.0.name}"
    }

    set {
      name  = "serviceType"
      value = "LoadBalancer"
    }
}