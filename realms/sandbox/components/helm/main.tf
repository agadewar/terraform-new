terraform {
  backend "azurerm" {
    key = "helm.tfstate"
  }
}

# provider "azurerm" {
#   version         = "1.30.1"
#   subscription_id = var.subscription_id
#   client_id       = var.service_principal_app_id
#   client_secret   = var.service_principal_password
#   tenant_id       = var.service_principal_tenant
# }


provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  service_account = kubernetes_service_account.tiller.metadata[0].name
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

# data "terraform_remote_state" "network" {
#   backend = "azurerm"

#   config = {
#     access_key           = var.realm_backend_access_key
#     storage_account_name = var.realm_backend_storage_account_name
#     container_name       = var.realm_backend_container_name
#     key                  = "network.tfstate"
#   }
# }

locals {
  config_path = "../kubernetes/kubeconfig"

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
