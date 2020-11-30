terraform {
  backend "azurerm" {
    key = "kubernetes.tfstate"
  }
}

provider "azurerm" {
  version = "1.43.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
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

data "terraform_remote_state" "log_analytics_workspace" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "log-analytics-workspace.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "network.tfstate"
  }
}

locals {
  config_path = ".local/kubeconfig"

  cluster_name                 = "${var.realm}-red"
  node_pool_profile_1_name    = "pool01"
  node_pool_profile_2_name    = "pool02"
  node_pool_profile_3_name    = "pool03"
  dns_prefix                   = "${var.realm}-red"
  linux_profile_admin_username = "sapience"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Kubernetes"
    },
  )
}

### Kubernetes (incl. autoscaler)

resource "azurerm_kubernetes_cluster" "kubernetes-red" {
  lifecycle {
    #ignore_changes  = [node_pool_profile[0].count]
    prevent_destroy = "false"
  }

  name                = local.cluster_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.dns_prefix
  kubernetes_version = var.kubernetes_version
  network_profile {
            load_balancer_sku  = "Standard"
            network_plugin     = "kubenet"
        }
  role_based_access_control {
    enabled = true
  }

  linux_profile {
    admin_username = local.linux_profile_admin_username

    ssh_key {
      key_data = file("../../../../config/${var.cloud}-${var.realm}/id_rsa.pub")
    }
  }

  default_node_pool {
    name                 = local.node_pool_profile_1_name
    type                 = "VirtualMachineScaleSets"
    vm_size              = var.kubernetes_pool01_vm_size
    #os_type             = var.kubernetes_pool01_os_type
    os_disk_size_gb      = var.kubernetes_pool01_os_disk_size_gb
    enable_auto_scaling  = true
    min_count            = var.kubernetes_pool01_min_count
    max_count            = var.kubernetes_pool01_max_count
    max_pods              = 250
    vnet_subnet_id       = data.terraform_remote_state.network.outputs.aks-pool2_subnet_id
  }

  addon_profile {
    kube_dashboard { enabled = true }

    oms_agent {
      enabled = false
      # log_analytics_workspace_id = data.terraform_remote_state.log_analytics_workspace.outputs.log_analytics_workspace_id   # https://github.com/terraform-providers/terraform-provider-azurerm/issues/3457
    }
  } 

  service_principal {
    client_id     = var.service_principal_app_id
    client_secret = var.service_principal_password
  }

  tags = merge(local.common_tags, {})
}

resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.kubernetes-red]

  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "rm -f ${local.config_path}"
  }

  provisioner "local-exec" {
    command = "az aks get-credentials --subscription ${var.subscription_id} --resource-group ${azurerm_kubernetes_cluster.kubernetes-red.resource_group_name} --name ${azurerm_kubernetes_cluster.kubernetes-red.name} -f ${local.config_path}"
  }
}

#data "template_file" "node_resource_group" {
#  template = file("templates/node_resource_group.tpl")

#  vars = {
#    resource_group = azurerm_kubernetes_cluster.kubernetes.resource_group_name
#    cluster_name   = azurerm_kubernetes_cluster.kubernetes.name
#    location       = azurerm_kubernetes_cluster.kubernetes.location
#  }
#}  
