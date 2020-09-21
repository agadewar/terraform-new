terraform {
  backend "azurerm" {
    key = "red/openfaas.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  
  subscription_id = var.global_subscription_id
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

data "terraform_remote_state" "ingress_controller" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
	  container_name       = var.realm_backend_container_name
    key                  = "red/ingress-controller.tfstate"
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

    labels = {
      vault-env = var.environment
    }
  }
}

data "helm_repository" "openfaas" {
  name = "openfaas"
  url  = "https://openfaas.github.io/faas-netes/"
}

data "template_file" "tls" {
  template = file("templates/tls.yaml.tpl")

  vars = {
    environment = var.environment
    dns_realm = var.dns_realm
    region = var.region
    cloud = var.cloud
  }
}

resource "helm_release" "openfaas" {
  name       = "openfaas"
  repository = data.helm_repository.openfaas.metadata[0].name
  namespace  = kubernetes_namespace.openfaas.metadata[0].name
  chart      = "openfaas"

  values = [
    data.template_file.tls.rendered
  ]

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
    name  = "exposeServices"
    value = "false"
  }
}

resource "azurerm_dns_a_record" "openfaas_red" {
  name                = "openfaas.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global-us"
  ttl                 = 30
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  records = [data.terraform_remote_state.ingress_controller.outputs.nginx_ingress_controller_ip]
}

resource "kubernetes_service_account" "vault" {
  metadata {
    name      = "vault-${var.environment}"
    namespace = kubernetes_namespace.openfaas-fn.metadata[0].name
  }

  automount_service_account_token = true
}


resource "kubernetes_cluster_role_binding" "vault_server_binding" {
  metadata {
    name      = "vault-${var.environment}-openfaas-fn-server-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault.metadata[0].name
    namespace = kubernetes_service_account.vault.metadata[0].namespace
  }
}