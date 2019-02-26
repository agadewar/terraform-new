terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.kubernetes-namespace.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

provider "kubernetes" {
  version = "1.5.0"

  config_path = "../../lab/kubernetes/kubeconfig"
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.kubernetes.terraform.tfstate"
  }
}

/* provider "null" {
  version = "2.0.0"
}

provider "template" {
  version = "2.0.0"
} */

/* data "terraform_remote_state" "resource_group" {
  backend = "azurerm"

  config {
    access_key           = "lo8HUaHNNDrFRHsTL+5uNuykv+WfQSHNxgXWqdcxE2vbk/eiSgaZx+gP2bHdU9TWKJk+PqhhyB0wY95wOCLDoQ=="
    storage_account_name = "tfstatelower"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
} */

locals {
  subscription_id           = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"
  namespace = "dev"
/*   kubernetes_version        = "1.11.7" */
/*   cluster_name              = "lab" */
/*   min_count                 = "2"
  max_count                 = "8"
  agent_pool_profile_1_name = "default" */
  # dns_prefix                = "lab"
/*   subscription_id           = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"
  app_id                    = "e68bc794-bad9-4605-9a84-69722969e2fc"
  tenant                    = "9c5c9da2-8ba9-4f91-8fa6-2c4382395477"
  password                  = "1b24afc1-3f4e-4351-8727-29917fde1991" */


  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Dev"
    Component = "Kubernetes Namespace"
    ManagedBy = "Terraform"
  }
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
