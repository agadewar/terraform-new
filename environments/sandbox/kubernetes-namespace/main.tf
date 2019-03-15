terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.sandbox.kubernetes-namespace.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

provider "kubernetes" {
  version = "1.5.0"
  config_path = "../../../realms/sandbox/kubernetes/kubeconfig"
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config {
    access_key           = "${local.backend_access_key}"
    storage_account_name = "${local.backend_storage_account_name}"
	  container_name       = "${local.backend_container_name}"
    key                  = "sapience.sandbox.sandbox.kubernetes.terraform.tfstate"
  }
}

locals {
  subscription_id = "${var.subscription_id}"
  backend_access_key = "${var.backend_access_key}"
  backend_storage_account_name = "${var.backend_storage_account_name}"
  backend_container_name = "${var.backend_container_name}"
  namespace = "sandbox"

  common_tags = "${merge(
    var.common_tags,
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

resource "kubernetes_resource_quota" "resource_quota" {
  metadata {
    name = "resource-quota-${local.namespace}"
    namespace = "${local.namespace}"
  }

  spec {
    hard {
      requests.memory = "7Gi"
      requests.cpu = "2"
    }
  }
}

resource "azurerm_public_ip" "aks_egress" {
  name                = "aks-egress-${local.namespace}"
  location            = "${data.terraform_remote_state.kubernetes.kubernetes_location}"
  # resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  resource_group_name = "${data.terraform_remote_state.kubernetes.kubernetes_node_resource_group_name}"
  public_ip_address_allocation = "Static"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "kubernetes_service" "aks_egress" {
  metadata {
    labels {
      "app.kubernetes.io/name" = "azure-egress"
    }

    name = "azure-egress"
    namespace = "${local.namespace}"
  }

  spec {
    load_balancer_ip = "${azurerm_public_ip.aks_egress.ip_address}"
    type = "LoadBalancer"
    port {
      port = "80"
    }
  }
}
