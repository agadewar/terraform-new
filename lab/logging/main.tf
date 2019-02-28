terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.efk.terraform.tfstate"
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
  
  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Lab"
    Component = "EFK"
    ManagedBy = "Terraform"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
  }
}


resource "helm_repository" "akomljen_charts" {
    name = "akomljen-charts"
    url  = "https://raw.githubusercontent.com/komljen/helm-charts/master/charts/"
}

resource "helm_release" "es_operator" {
    name       = "es-operator"
    namespace = "${local.namespace}"
    repository = "${helm_repository.akomljen_charts.name}"
    chart      = "akomljen-charts/elasticsearch-operator"
}

resource "helm_release" "efk" {
    name       = "efk"
    namespace = "${local.namespace}"
    repository = "${helm_repository.akomljen_charts.name}"
    chart      = "akomljen-charts/efk"
}




