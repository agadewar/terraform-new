terraform {
  backend "azurerm" {
    key = "red/kubernetes.tfstate"
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
  node_pool_profile_name       = "pool01"
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

resource "azurerm_kubernetes_cluster" "kubernetes" {
  lifecycle {
    prevent_destroy = "false"
  }

  name                                  = local.cluster_name
  location                              = var.resource_group_location
  resource_group_name                   = var.resource_group_name
  dns_prefix                            = local.dns_prefix
  #api_server_authorized_ip_ranges       = var.api_auth_ips
  kubernetes_version                    = var.kubernetes_red_version

  network_profile {
            #dns_service_ip     = "10.0.0.10"
            #docker_bridge_cidr = "172.17.0.1/16"
            load_balancer_sku  = "Standard"
            network_plugin     = "kubenet"
            #pod_cidr           = "10.244.0.0/16"
            #service_cidr       = "10.0.0.0/16"
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
    name                 = local.node_pool_profile_name
    type                 = "VirtualMachineScaleSets"
    #load_balancer_sku    = "standard"
    vm_size              = var.kubernetes_pool01_vm_size
    os_disk_size_gb      = var.kubernetes_pool01_os_disk_size_gb
    enable_auto_scaling  = true
    min_count            = var.kubernetes_pool01_min_count
    max_count            = var.kubernetes_pool01_max_count
    max_pods             = var.kubernetes_pool01_max_pods
    vnet_subnet_id       = data.terraform_remote_state.network.outputs.aks-pool_subnet_id
  }
  addon_profile {
    #kube_dashboard { enabled = false }

    oms_agent {
      enabled = false
      }
  } 

  service_principal {
    client_id     = var.service_principal_app_id
    client_secret = var.service_principal_password
  }

  tags = merge(local.common_tags, {})
  
}  

  resource "null_resource" "kubeconfig" {
   depends_on = [azurerm_kubernetes_cluster.kubernetes]

   triggers = {
    timestamp = "${timestamp()}"
   }

   provisioner "local-exec" {
    command = "rm -f ${local.config_path}"
   }

   provisioner "local-exec" {
    command = "az aks get-credentials --subscription ${var.subscription_id} --resource-group ${azurerm_kubernetes_cluster.kubernetes.resource_group_name} --name ${azurerm_kubernetes_cluster.kubernetes.name} -f ${local.config_path}"
  }
}
   
  #data "template_file" "node_resource_group" {
  #template = file("autoscaler/node_resource_group.tpl")

  #vars = {
  #  resource_group = azurerm_kubernetes_cluster.kubernetes.resource_group_name
  #  cluster_name   = azurerm_kubernetes_cluster.kubernetes.name
  #  location       = azurerm_kubernetes_cluster.kubernetes.location
  #}
#}
   
  