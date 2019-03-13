terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.sandbox.monitoring.terraform.tfstate"
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
  namespace = "monitoring"
  
  common_tags = "${map(
    "Customer", "Sapience",
    "Product", "Sapience",
    "Realm", "Sandbox",
    "Component", "Monitoring",
    "ManagedBy", "Terraform"
    )}"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
  }
}

#See: https://akomljen.com/get-kubernetes-cluster-metrics-with-prometheus-in-5-minutes/

resource "helm_release" "prometheus" {
    name       = "prometheus"
    namespace  = "${local.namespace}"
    chart      = "stable/prometheus-operator"
    values = [
      "${file("custom-values.yaml")}"
    ]
}
