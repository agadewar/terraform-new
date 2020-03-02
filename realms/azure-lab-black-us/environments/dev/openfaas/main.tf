terraform {
  backend "azurerm" {
    key = "black/openfaas.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "kubernetes" {
  config_path = local.config_path
}

provider "helm" {
  version = "1.0.0"
  kubernetes {
    config_path = local.config_path
  }
}

locals {
  resource_group_name = var.resource_group_name
  config_path         = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "OpenFaaS"
    },
  )
}

resource "kubernetes_namespace" "openfaas" {
  metadata {
    name = "${var.environment}-openfaas"
  }
}

resource "kubernetes_namespace" "openfaas-fn" {
  metadata {
    name = "${var.environment}-openfaas-fn"
  }
}

data "helm_repository" "openfaas" {
  name = "openfaas"
  url  = "https://openfaas.github.io/faas-netes/"
}

resource "helm_release" "openfaas" {
  name       = "openfaas"
  repository = data.helm_repository.openfaas.metadata[0].name
  namespace  = kubernetes_namespace.openfaas.metadata[0].name
  chart      = "openfaas"

  set {
    name  = "basic_auth"
    value = "true"
  }

  set {
    name  = "generateBasicAuth"
    value = "true"
  }

  set {
    name  = "functionNamespace"
    value = kubernetes_namespace.openfaas-fn.metadata[0].name
  }
  
  set {
    name  = "gateway.nodePort"
    value = var.openfaas_gateway_nodeport
  }
}
