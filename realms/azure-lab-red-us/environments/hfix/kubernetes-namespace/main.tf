terraform {
  backend "azurerm" {
    key = "red/kubernetes-namespace.tfstate"
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
  version = "1.7.0"
  config_path = "${local.config_path}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config = {
    access_key           = "${var.realm_backend_access_key}"
    storage_account_name = "${var.realm_backend_storage_account_name}"
	  container_name       = "${var.realm_backend_container_name}"
    key                  = "red/kubernetes.tfstate"
  }
}

locals {
  namespace = "${var.environment}"

  config_path = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Kubernetes Namespace"
    )
  )}"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
  }
}

resource "null_resource" "default_token_secret_name" {
  depends_on = [ "kubernetes_namespace.namespace" ]

  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "mkdir -p .local && kubectl --kubeconfig=${local.config_path} get secret --namespace ${local.namespace} | grep \"default-token\" | cut -d' ' -f1 | tr -d $'\n' > .local/default_token_secret_name.out"
  }
}