terraform {
  backend "azurerm" {
    key = "sisense.tfstate"
  }
}

provider "azurerm" {
  version = "2.1.0"

  features {}
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
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

# ----------------------------------------------------------------------------------------------------------
# PURPOSE: Provider
# ----------------------------------------------------------------------------------------------------------

provider "helm" {

  alias                                      = "sisense"
  kubernetes {  
    load_config_file                         = "false"
    host                                     = azurerm_kubernetes_cluster.sisense.kube_config.0.host
    username                                 = azurerm_kubernetes_cluster.sisense.kube_config.0.username
    password                                 = azurerm_kubernetes_cluster.sisense.kube_config.0.password
    client_certificate                       = base64decode(azurerm_kubernetes_cluster.sisense.kube_config.0.client_certificate)
    client_key                               = base64decode(azurerm_kubernetes_cluster.sisense.kube_config.0.client_key)
    cluster_ca_certificate                   = base64decode(azurerm_kubernetes_cluster.sisense.kube_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {

  alias                                      = "sisense"
  load_config_file                           = "false"
  host                                       = azurerm_kubernetes_cluster.sisense.kube_config.0.host
  client_certificate                         = base64decode(azurerm_kubernetes_cluster.sisense.kube_config.0.client_certificate)
  client_key                                 = base64decode(azurerm_kubernetes_cluster.sisense.kube_config.0.client_key)
  cluster_ca_certificate                     = base64decode(azurerm_kubernetes_cluster.sisense.kube_config.0.cluster_ca_certificate)

}

# ----------------------------------------------------------------------------------------------------------
#
# DEPLOYMENT: AZURE
#
# ----------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------
# PURPOSE: Kubernetes Clusters
# ----------------------------------------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "sisense" {
    
  name                                       = "lab-us-sisense"
  resource_group_name                        = var.resource_group_name
  location                                   = var.resource_group_location
  dns_prefix                                 = "lab-us-sisense"
  kubernetes_version                         = "1.15.10"
  default_node_pool {
    name                                     = "default"
    vnet_subnet_id                           = "/subscriptions/b78a61e7-f2ed-4cb0-8f48-6548408935e9/resourceGroups/lab-us/providers/Microsoft.Network/virtualNetworks/lab-us/subnets/lab-us-sisense"
    enable_auto_scaling                      = "true"
    type                                     = "VirtualMachineScaleSets"
    os_disk_size_gb                          = "100"
    min_count                                = "1"
    max_count                                = "3"
    max_pods                                 = 250
    vm_size                                  = "Standard_D4_v3"
    node_labels                              = { "app" : "default" }
  }
  
  network_profile {
    network_plugin                           = "azure"
    network_policy                           = "calico"
  }
  linux_profile {
    admin_username                           = "azureuser"
    ssh_key {
      key_data                               = var.public_ssh_key
    }
  }
  addon_profile { 
    kube_dashboard { 
      enabled                                = true 
    }
  } 
  service_principal {
    client_id                                = var.service_principal_app_id
    client_secret                            = var.service_principal_password
  }
}

# ----------------------------------------------------------------------------------------------------------
#
# DEPLOYMENTS: KUBERNETES / HELM
#
# ----------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------
# PURPOSE: Kubernetes Namespace
# ----------------------------------------------------------------------------------------------------------

resource "kubernetes_namespace" "cert_manager" {

  provider                                   = kubernetes.sisense
  metadata {
    name                                     = "cert-manager"    
  }
}

# ----------------------------------------------------------------------------------------------------------
# PURPOSE: Kubernetes Secrets
# ----------------------------------------------------------------------------------------------------------


resource "kubernetes_secret" "cert_manager_service_account" {

  provider                                   = kubernetes.sisense
  metadata {
    name                                     = "service-account"
    namespace                                = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    password                                 = var.service_principal_password
  }
  type                                       = "Opaque"

}

# -------------------------------------------------------------------------------
# PURPOSE: Custom-Resource-Definitions Private Helm Chart
# SUMMARY: To deploy CRDs to Kubernetes
# -------------------------------------------------------------------------------

resource "helm_release" "custom_resource_definitions" {
  
  depends_on                                 = [ kubernetes_namespace.cert_manager ]
  provider                                   = helm.sisense
  namespace                                  = kubernetes_namespace.cert_manager.metadata[0].name
  name                                       = "custom-resource-definitions"
  chart                                      = "${path.module}/charts/custom-resource-definitions"

}

# -----------------------------------------------------------------------------------------
# PURPOSE: Cert-Manager-Cluster-Issuers Private Helm Chart & Cert-Manager Public Helm Chart
# SUMMARY: A native Kubernetes certificate management controller
#          https://cert-manager.io/docs/
# -----------------------------------------------------------------------------------------

resource "helm_release" "cert_manager_cluster_issuers" {
  
  depends_on                                 = [ helm_release.custom_resource_definitions, kubernetes_secret.cert_manager_service_account ]
  provider                                   = helm.sisense
  namespace                                  = kubernetes_namespace.cert_manager.metadata[0].name
  name                                       = "cert-manager-cluster-issuers"
  chart                                      = "${path.module}/charts/cert-manager-cluster-issuers"

}

/* resource "helm_release" "cert_manager" {

  depends_on                                 = [helm_release.cert_manager_cluster_issuers]
  provider                                   = helm.sisense
  name                                       = "cert-manager"
  repository                                 = "https://charts.jetstack.io" 
  namespace                                  = kubernetes_namespace.cert_manager.metadata[0].name
  chart                                      = "cert-manager"
  version                                    = "v0.13.1"

  set { 
    name                                     = "nodeSelector.app"
    value                                    = "default"
  }

  set {
    name                                     = "webhook.enabled"
    value                                    = "false"
  }

  set {
    name                                     = "resources.requests.cpu"
    value                                    = "10m"
  }

  set {
    name                                     = "resources.requests.memory"
    value                                    = "32Mi"
  }

}

# -----------------------------------------------------------------------------------
# PURPOSE: Nginx-Ingress Public Helm Chart
# SUMMARY: An Ingress controller that uses ConfigMap to store the nginx configuration
#          https://github.com/helm/charts/tree/master/stable/nginx-ingress
# -----------------------------------------------------------------------------------

resource "helm_release" "nginx_ingress" {

  depends_on                                 = [ helm_release.cert_manager ]
  provider                                   = helm.sisense
  name                                       = "nginx-ingress"
  namespace                                  = "kube-system"
  repository                                 = "https://kubernetes-charts.storage.googleapis.com" 
  chart                                      = "nginx-ingress"
  timeout                                    = 600

  set {
    name                                     = "controller.nodeSelector.app"
    value                                    = "default"
  }

  set {
    name                                     = "controller.replicaCount"
    value                                    = 3
  }

  set {
    name                                     = "controller.service.externalTrafficPolicy"
    value                                    = "Local"
  }

  set {
    name                                     = "controller.resources.requests.cpu"
    value                                    = "500m"
  }

  set {
    name                                     = "controller.resources.requests.memory"
    value                                    = "250Mi"
  }
  
}  */