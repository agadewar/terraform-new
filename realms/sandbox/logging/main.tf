terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.sandbox.logging.terraform.tfstate"
  }
}

provider "kubernetes" {
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
  config_path = "../kubernetes/kubeconfig"
  namespace = "logging"
  
  common_tags = "${merge(
    var.common_tags,
      map(
        "Component", "Logging"
      )
  )}"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
  }
}

# See: https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes/
data "helm_repository" "akomljen_charts" {
    name = "akomljen-charts"
    url  = "https://raw.githubusercontent.com/komljen/helm-charts/master/charts/"
}

resource "helm_release" "es_operator" {
    name       = "es-operator"
    namespace = "${local.namespace}"
    repository = "${data.helm_repository.akomljen_charts.name}"
    chart      = "akomljen-charts/elasticsearch-operator"
}

resource "helm_release" "efk" {
    depends_on = [ "helm_release.es_operator" ]

    name       = "efk"
    namespace = "${local.namespace}"
    repository = "${data.helm_repository.akomljen_charts.name}"
    chart      = "akomljen-charts/efk"
}
