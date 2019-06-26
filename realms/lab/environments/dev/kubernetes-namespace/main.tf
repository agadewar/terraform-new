terraform {
  backend "azurerm" {
    key = "kubernetes-namespace.tfstate"
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

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "kubernetes.tfstate"
  }
}

locals {
  namespace = "${var.environment}"

  config_path = "../../../components/kubernetes/kubeconfig"

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

# data "local_file" "default_token_secret_name" {
#   depends_on = [ "null_resource.default_token_secret_name" ]

#   filename = ".local/default_token_secret_name.out"
# }
# see: https://github.com/hashicorp/terraform/issues/11806
data "null_data_source" "default_token_secret_name" {
  inputs = {
    dummy = "${format(null_resource.default_token_secret_name.id)}"
    data = "${file(".local/default_token_secret_name.out")}"
  }
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
  // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
  //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
  metadata {
    labels {
      "sapienceanalytics.com/name" = "azure-egress"
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
