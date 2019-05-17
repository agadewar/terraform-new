terraform {
  backend "azurerm" {
    key = "sapience.environment.dev.kubernetes-namespace.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

provider "kubernetes" {
  version = "1.5.0"
  config_path = "${local.config_path}"
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.realm.${var.realm}.kubernetes.terraform.tfstate"
  }
}

locals {
  namespace = "${var.environment}"

  config_path = "../../../../../realms/${var.realm}/components/kubernetes/kubeconfig"

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

  # triggers = {
  #   timestamp = "${timestamp()}"
  # }

  provisioner "local-exec" {
    command = "mkdir -p .local && kubectl --kubeconfig=${local.config_path} get secret --namespace ${local.namespace} | grep \"default-token\" | cut -d' ' -f1 | tr -d $'\n' > .local/default_token_secret_name.out"
  }
}

data "local_file" "default_token_secret_name" {
  depends_on = [ "null_resource.default_token_secret_name" ]

  filename = ".local/default_token_secret_name.out"
}

resource "kubernetes_resource_quota" "resource_quota" {
  metadata {
    name      = "resource-quota-${local.namespace}"
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
  location            = "${var.resource_group_location}"
  location            = "${data.terraform_remote_state.kubernetes.kubernetes_location}"
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
