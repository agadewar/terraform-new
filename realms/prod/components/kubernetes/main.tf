terraform {
  backend "azurerm" {
    key = "kubernetes.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
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

  cluster_name                 = var.realm
  agent_pool_profile_1_name    = "pool01"
  dns_prefix                   = var.realm
  linux_profile_admin_username = "banyan"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Kubernetes"
    },
  )
}

# resource "azurerm_route_table" "agent_pool_profile_1" {
#   name                = "${local.agent_pool_profile_1_name}"
#   location            = "${var.resource_group_location}"
#   resource_group_name = "${var.resource_group_name}"

#   route {
#     name                   = "default"
#     address_prefix         = "10.100.0.0/14"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.10.1.1"
#   }
# }

// Now managed in the Network component.  Can delete this.
// resource "azurerm_subnet" "agent_pool_profile_1" {
//   name                 = "aks-${local.agent_pool_profile_1_name}"
//   resource_group_name  = var.resource_group_name
//   virtual_network_name = data.terraform_remote_state.network.outputs.realm_network_name
//   address_prefix       = var.subnet_address_prefix_kubernetes_agent_pool_profile_1
// }

# resource "azurerm_subnet_route_table_association" "agent_pool_profile_1" {
#   subnet_id      = "${azurerm_subnet.example.id}"
#   route_table_id = "${azurerm_route_table.example.id}"
# }

resource "azurerm_kubernetes_cluster" "kubernetes" {
  lifecycle {
    ignore_changes  = [agent_pool_profile.0.count]
    prevent_destroy = "false"
  }

  name                = local.cluster_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.dns_prefix

  kubernetes_version = var.kubernetes_version

  linux_profile {
    admin_username = local.linux_profile_admin_username

    ssh_key {
      key_data = file(var.kubernetes_linux_profile_ssh_key_loc)
    }
  }

  network_profile {
    network_plugin = "azure"
  }

  agent_pool_profile {
    name            = local.agent_pool_profile_1_name
    count           = var.kubernetes_pool01_min_count
    vm_size         = var.kubernetes_pool01_vm_size
    os_type         = var.kubernetes_pool01_os_type
    os_disk_size_gb = 30

    vnet_subnet_id = data.terraform_remote_state.network.outputs.aks-pool01_subnet_id
  }

  service_principal {
    client_id     = var.service_principal_app_id
    client_secret = var.service_principal_password
  }

  tags = merge(local.common_tags, {})
}

resource "null_resource" "kubeconfig" {
  depends_on = [ azurerm_kubernetes_cluster.kubernetes ]

  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "rm -f ${local.config_path}"
  }

  provisioner "local-exec" {
    command = "mkdir -p .local && az aks get-credentials --subscription ${var.subscription_id} --resource-group ${azurerm_kubernetes_cluster.kubernetes.resource_group_name} --name ${azurerm_kubernetes_cluster.kubernetes.name} -f ${local.config_path}"
  }
}

data "template_file" "node_resource_group" {
  template = file("autoscaler/node_resource_group.tpl")

  vars = {
    resource_group = azurerm_kubernetes_cluster.kubernetes.resource_group_name
    cluster_name   = azurerm_kubernetes_cluster.kubernetes.name
    location       = azurerm_kubernetes_cluster.kubernetes.location
  }
}

data "template_file" "autoscaler_config_pool01" {
  template = file("autoscaler/cluster-autoscaler-containerservice.yaml.tpl")

  vars = {
    autoscaler_client_id           = base64encode(var.service_principal_app_id)
    autoscaler_client_secret       = base64encode(var.service_principal_password)
    autoscaler_resource_group      = base64encode(azurerm_kubernetes_cluster.kubernetes.resource_group_name)
    autoscaler_subscription_id     = base64encode(var.subscription_id)
    autoscaler_tenant_id           = base64encode(var.service_principal_tenant)
    autoscaler_cluster_name        = base64encode(azurerm_kubernetes_cluster.kubernetes.name)
    autoscaler_node_resource_group = base64encode(data.template_file.node_resource_group.rendered)
    autoscaler_minimum             = var.kubernetes_pool01_min_count
    autoscaler_maximum             = var.kubernetes_pool01_max_count
    autoscaler_agentpool           = local.agent_pool_profile_1_name
    autoscaler_version             = "v1.15.0"
  }
}

resource "null_resource" "kubernetes_config_autoscaler_kubernetes_autoscaler_config_pool01" {
  depends_on = [ null_resource.kubeconfig ]

  triggers = {
    autoscaler_config_changed = data.template_file.autoscaler_config_pool01.rendered
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.autoscaler_config_pool01.rendered}\nEOF"
  }
}

# resource "null_resource" "create_cert_manager_crd" {
#   depends_on = [null_resource.kubeconfig]

#   triggers = {
#     manifest_sha1 = sha1(file("files/cert-manager-crds.yaml"))
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply --kubeconfig=${local.config_path} -f -<<EOF\n${file("files/cert-manager-crds.yaml")}\nEOF"
#   }

#   provisioner "local-exec" {
#     when = destroy

#     command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition challenges.certmanager.k8s.io --ignore-not-found"
#   }

#   provisioner "local-exec" {
#     when = destroy

#     command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition issuers.certmanager.k8s.io --ignore-not-found"
#   }

#   provisioner "local-exec" {
#     when = destroy

#     command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition orders.certmanager.k8s.io --ignore-not-found"
#   }

#   provisioner "local-exec" {
#     when = destroy

#     command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition certificates.certmanager.k8s.io --ignore-not-found"
#   }

#   provisioner "local-exec" {
#     when = destroy

#     command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition clusterissuers.certmanager.k8s.io --ignore-not-found"
#   }
# }

