terraform {
  backend "azurerm" {
    key = "black/helm.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  service_account = "tiller"
}

provider "kubernetes" {
  config_path = local.config_path
}

provider "null" {
  version = "2.1.2"
}

provider "template" {
  version = "2.1.2"
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Helm"
    },
  )
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    annotations = merge(local.common_tags, {})

    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_rule" {
  depends_on = [ kubernetes_service_account.tiller ]

  metadata {
    annotations = merge(local.common_tags, {})

    name = "tiller-cluster-rule"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
    api_group = ""
  }
}

resource "null_resource" "helm_init" {
  depends_on = [ kubernetes_cluster_role_binding.tiller_cluster_rule ]

  provisioner "local-exec" {
    command = "helm --kubeconfig ${local.config_path} init --service-account tiller --automount-service-account-token --upgrade"
  }
}
