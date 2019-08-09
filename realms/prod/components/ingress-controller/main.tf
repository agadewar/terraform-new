terraform {
  backend "azurerm" {
    key = "ingress-controller.tfstate"
  }
}

provider "azurerm" {
  version         = "1.30.1"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "kubernetes" {
  config_path = local.config_path
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  service_account = "tiller"
}

locals {
  config_path         = "../kubernetes/.local/kubeconfig"

  resource_group_name = var.resource_group_name

  namespace           = "kube-system"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Ingress Controller"
    },
  )
}

# resource "kubernetes_config_map" "tcp_services" {
#   metadata {
#     name = "tcp-services"
#     namespace = "kube-system"
#   }

#   # data = {
#   #   9092  = "sandbox/kafka:9092"
#   #   31090 = "sandbox/kafka-0-external:31090"
#   #   31091 = "sandbox/kafka-1-external:31091"
#   #   31092 = "sandbox/kafka-2-external:31092"
#   # }
# }

resource "helm_release" "nginx_ingress" {
  name      = "nginx-ingress"
  namespace = "kube-system"
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

  set {
    name  = "defaultBackend.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "defaultBackend.resources.requests.memory"
    value = "100Mi"
  }

  # set {
  #   name  = "controller.extraArgs.tcp-services-configmap"
  #   value = "kube-system/tcp-services"
  # }

#   set {
#     name  = "tcp"
#     value = "{ 9092 = 9092 }"
# #     value = <<EOT
# # |-
# #   9092: 9092
# #   31090: 31090
# #   31091: 31091
# #   31092: 31092
# # EOT
#   }

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

