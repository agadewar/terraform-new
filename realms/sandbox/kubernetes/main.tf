terraform {
  backend "azurerm" {
    key                  = "sapience.sandbox.sandbox.kubernetes.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

/* provider "kubernetes" {
  version = "1.5.0"

  config_path = "../kubernetes/kubeconfig"
} */

provider "null" {
  version = "2.0.0"
}

provider "template" {
  version = "2.0.0"
}

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"

  config {
    access_key           = "${local.backend_access_key}"
    storage_account_name = "${local.backend_storage_account_name}"
	  container_name       = "${local.backend_container_name}"
    key                  = "sapience.sandbox.sandbox.resource-group.terraform.tfstate"
  }
}

locals {
  kubernetes_version        = "1.12.5"
  cluster_name              = "lab"
  min_count                 = "2"
  max_count                 = "8"
  agent_pool_profile_1_name = "default"
  agent_pool_profile_1_vm_size = "Standard_D2_v2"
  dns_prefix                = "${local.cluster_name}"
  subscription_id = "c57d6dfd-85ff-46a6-8038-1f6d97197cb6"
  backend_access_key = "${var.backend_access_key}"
  backend_storage_account_name = "${var.backend_storage_account_name}"
  backend_container_name    = "${var.backend_container_name}"
  app_id                    = "e68bc794-bad9-4605-9a84-69722969e2fc"
  tenant                    = "9c5c9da2-8ba9-4f91-8fa6-2c4382395477"
  kubernetes_password       = "${var.kubernetes_password}"
  linux_profile_admin_username = "sapience"
  linux_profile_ssh_key_loc = "/home/scardis/.ssh/id_rsa.pub"
  common_tags = "${map(
    "Customer", "Sapience",
    "Product", "Sapience",
    "Realm", "Sandbox",
    "Component", "Kubernetes",
    "ManagedBy", "Terraform"
  )}"
}

#See: https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks
#See: https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html
resource "azurerm_kubernetes_cluster" "kubernetes" {
  name                = "${local.cluster_name}"
  location            = "${data.terraform_remote_state.resource_group.resource_group_location}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  dns_prefix          = "${local.dns_prefix}"

  kubernetes_version  =  "${local.kubernetes_version}"

  linux_profile {
      admin_username = "${local.linux_profile_admin_username}"

      ssh_key {
        key_data = "${file("${local.linux_profile_ssh_key_loc}")}"
      }
  }

  agent_pool_profile {
    name            = "${local.agent_pool_profile_1_name}"
    count           = "${local.min_count}"
    vm_size         = "${local.agent_pool_profile_1_vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${local.app_id}"
    client_secret = "${local.kubernetes_password}"
  }

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

#See: https://docs.microsoft.com/en-us/azure/aks/autoscaler
#See: https://github.com/underguiz/terraform-aks-autoscaler
data "template_file" "node_resource_group" {
  template = "${file("autoscaler/node_resource_group.tpl")}"

  vars {
     resource_group = "${azurerm_kubernetes_cluster.kubernetes.resource_group_name}"
     cluster_name   = "${azurerm_kubernetes_cluster.kubernetes.name}"
     location       = "${azurerm_kubernetes_cluster.kubernetes.location}"
  }
}

data "template_file" "autoscaler_config" {
  template = "${file("autoscaler/cluster-autoscaler-containerservice.yaml.tpl")}"

  vars {
    autoscaler_client_id           = "${base64encode(local.app_id)}"
    autoscaler_client_secret       = "${base64encode(local.kubernetes_password)}"
    autoscaler_resource_group      = "${base64encode(azurerm_kubernetes_cluster.kubernetes.resource_group_name)}"
    autoscaler_subscription_id     = "${base64encode(local.subscription_id)}"
    autoscaler_tenant_id           = "${base64encode(local.tenant)}"
    autoscaler_cluster_name        = "${base64encode(azurerm_kubernetes_cluster.kubernetes.name)}"
    autoscaler_node_resource_group = "${base64encode(data.template_file.node_resource_group.rendered)}"
    autoscaler_minimum             = "${local.min_count}"
    autoscaler_maximum             = "${local.max_count}"
    autoscaler_agentpool           = "${local.agent_pool_profile_1_name}"
    autoscaler_version             = "v1.13.0"
  }
}

resource "null_resource" "kubeconfig" {
  depends_on = ["azurerm_kubernetes_cluster.kubernetes"]

  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "rm -f kubeconfig"
  }

  provisioner "local-exec" {
    command = "az aks get-credentials --subscription ${local.subscription_id} --resource-group ${azurerm_kubernetes_cluster.kubernetes.resource_group_name} --name ${azurerm_kubernetes_cluster.kubernetes.name} -f kubeconfig"
  }
}

resource "null_resource" "kubernetes_config_autoscaler" {
  depends_on = ["null_resource.kubeconfig"]

  triggers {
    autoscaler_config_changed = "${data.template_file.autoscaler_config.rendered}"
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=kubeconfig -f - <<EOF\n${data.template_file.autoscaler_config.rendered}\nEOF"
  }
}


# ##### "dev" evironment (BEGIN)
# resource "kubernetes_namespace" "lab" {
#   depends_on = ["null_resource.kubeconfig"]

#   metadata {
#     name = "lab"
#   }
# }

# resource "kubernetes_resource_quota" "resource_quota_dev" {
#   metadata {
#     name = "resource-quota-dev"
#     namespace = "lab"
#   }

#   spec {
#     hard {
#       requests.memory = "7Gi"
#       requests.cpu = "2"
#     }
#   }
# }

# resource "azurerm_public_ip" "aks_egress_dev" {
#   name                = "aks-egress-dev"
#   location            = "${azurerm_kubernetes_cluster.kubernetes.location}"
#   # resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
#   resource_group_name = "${data.template_file.node_resource_group.rendered}"
#   public_ip_address_allocation   = "Static"

#   tags = "${merge(
#     local.common_tags,
#     map()
#   )}"
# }

# resource "kubernetes_service" "aks_egress_dev" {
#   metadata {
#     labels {
#       "app.kubernetes.io/name" = "azure-egress"
#     }

#     name = "azure-egress"
#     namespace = "lab"
#   }

#   spec {
#     load_balancer_ip = "${azurerm_public_ip.aks_egress_dev.ip_address}"
#     type = "LoadBalancer"
#     port {
#       port = "80"
#     }
#   }
# }
# ##### "dev" evironment (END)