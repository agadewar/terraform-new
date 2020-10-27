terraform {
  backend "azurerm" {
    key = "red/aks-egress.tfstate"
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
  config_path = local.config_path
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "AKS Egress"
    },
  )
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "kubernetes.tfstate"
  }
}

resource "azurerm_public_ip" "aks_egress" {
  name                = "aks-egress-${var.realm}"
  location            = "${data.terraform_remote_state.kubernetes.outputs.kubernetes_location}"
  resource_group_name = "${data.terraform_remote_state.kubernetes.outputs.kubernetes_node_resource_group_name}"
  
  public_ip_address_allocation = "Static"

  tags = "${merge(
    local.common_tags,
    {}
  )}"
}

resource "kubernetes_service" "aks_egress" {
  // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
  //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
  metadata {
    labels = {
      "sapienceanalytics.com/name" = "aks-egress"
    }

    name = "aks-egress"
    namespace = "default"
  }

  spec {
    load_balancer_ip = "${azurerm_public_ip.aks_egress.ip_address}"
    type = "LoadBalancer"
    port {
      port = "80"
    }
  }
}