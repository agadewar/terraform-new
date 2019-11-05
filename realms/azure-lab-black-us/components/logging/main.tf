terraform {
  backend "azurerm" {
    key = "black/logging.tfstate"
  }
}

# See: https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes/

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
  kubernetes {
    config_path = local.config_path
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace   = "logging"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Logging"
    },
  )
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

data "helm_repository" "akomljen_charts" {
  name = "akomljen-charts"
  url  = "https://raw.githubusercontent.com/komljen/helm-charts/master/charts/"
}

resource "helm_release" "es_operator" {
  name       = "es-operator"
  namespace  = local.namespace
  repository = data.helm_repository.akomljen_charts.name
  chart      = "akomljen-charts/elasticsearch-operator"
}

resource "helm_release" "efk" {
  depends_on = [helm_release.es_operator]

  name       = "efk"
  namespace  = local.namespace
  repository = data.helm_repository.akomljen_charts.name
  chart      = "akomljen-charts/efk"
}

# resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
#   name                = "sapience-${var.realm}"
#   resource_group_name = var.resource_group_name
#   location            = var.resource_group_location
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
# }