terraform {
  backend "azurerm" {
    key = "black/kubernetes-namespace.tfstate"
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

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config = {
    access_key           = "${var.realm_backend_access_key}"
    storage_account_name = "${var.realm_backend_storage_account_name}"
	  container_name       = "${var.realm_backend_container_name}"
    key                  = "black/kubernetes.tfstate"
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


/*  resource "kubernetes_resource_quota" "resource_quota" {
   #count = var.kubernetes_quota_memory == "none" && var.kubernetes_quota_cpu == "none" ? 0 : 1
   #count = var.kubernetes_quota_memory ? 1 : 0
   metadata {
     name      = "resource-quota-${local.namespace}"
     namespace = "${local.namespace}"
   }

   spec {
     hard =
       #"requests.memory" = var.kubernetes_quota_memory == "none" ? "10Gi" : var.kubernetes_quota_memory
       #"requests.cpu"    = var.kubernetes_quota_cpu == "none" ? "10Mi" : var.kubernetes_quota_cpu
       #"requests.memory" = "${(var.kubernetes_quota_memory == "none") ? "10Gi" : "20Gi"}"
       #"requests.cpu"    = var.kubernetes_quota_cpu == "none" ? "10Mi" : "20Mi"  
       #"${map("requests.memory", "${(var.kubernetes_quota_memory == "none") ? "10Gi" : "20Gi"}")}"
      
   }
 } */