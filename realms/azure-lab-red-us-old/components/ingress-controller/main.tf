terraform {
  backend "azurerm" {
    key = "red/ingress-controller.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

/* 
data "terraform_remote_state" "helm" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "red/helm.tfstate"
  }
} */

provider "helm" {
  version = "0.10.4"
  kubernetes {
    config_path = local.config_path
  }

  #service_account = data.terraform_remote_state.helm.outputs.tiller_service_account
}



# data "terraform_remote_state" "dns" {
#   backend = "azurerm"
#   config {
#     access_key           = "${var.backend_access_key}"
#     storage_account_name = "${var.backend_storage_account_name}"
# 	  container_name       = "realm-${var.realm}"
#     key                  = "dns.tfstate"
#   }
# }

locals {
  resource_group_name = var.resource_group_name
  config_path         = "../kubernetes/.local/kubeconfig"
  namespace           = "kube-system"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Ingress Controller"
    },
  )
}

resource "helm_release" "nginx_ingress" {
  name      = "nginx-ingress"
  namespace = local.namespace
  chart     = "stable/nginx-ingress"

  set {
    name  = "controller.replicaCount"
    value = var.nginx_ingress_replica_count
  }

  # See: https://docs.microsoft.com/en-us/azure/aks/ingress-tls
  # set {
  #   name  = "controller.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #   value = "linux"
  # }

  # set {
  #   name  = "defaultBackend.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #   value = "linux"
  # }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "100Mi"
  }

  timeout = 600
}

resource "null_resource" "nginx_ingress_controller_ip" {
  depends_on = [helm_release.nginx_ingress]

  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "mkdir -p .local && kubectl --kubeconfig ${local.config_path} -n kube-system get services -o json | jq -j '.items[] | select(.metadata.name == \"nginx-ingress-controller\") | .status .loadBalancer .ingress [0] .ip' > .local/nginx-ingress-controller-ip"
  }

  provisioner "local-exec" {
    when = destroy

    command = "rm -f .local/nginx-ingress-controller-ip"
  }
}

data "local_file" "nginx_ingress_controller_ip" {
  depends_on = [null_resource.nginx_ingress_controller_ip]

  filename = ".local/nginx-ingress-controller-ip"
}