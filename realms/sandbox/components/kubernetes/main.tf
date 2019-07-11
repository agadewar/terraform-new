terraform {
  backend "azurerm" {
    key = "kubernetes.tfstate"
  }
}

provider "azurerm" {
  version         = "1.30.1"
  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}


provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  service_account = kubernetes_service_account.tiller.metadata[0].name
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
  config_path = "./kubeconfig"

  cluster_name                 = var.realm
  agent_pool_profile_1_name    = "pool01"
  agent_pool_profile_2_name    = "pool02"
  dns_prefix                   = var.realm
  linux_profile_admin_username = "sapience"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Kubernetes"
    },
  )
}

resource "azurerm_subnet" "agent_pool_profile_1" {
  name                 = "aks-${local.agent_pool_profile_1_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.terraform_remote_state.network.outputs.realm_network_name
  address_prefix       = var.subnet_address_prefix_kubernetes_pool01
}

// resource "azurerm_subnet" "agent_pool_profile_2" {
//   name                 = "aks-${local.agent_pool_profile_2_name}"
//   resource_group_name  = var.resource_group_name
//   virtual_network_name = data.terraform_remote_state.network.outputs.realm_network_name
//   address_prefix       = var.subnet_address_prefix_kubernetes_pool02
// }

### Kubernetes (incl. autoscaler)

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
    vnet_subnet_id  = azurerm_subnet.agent_pool_profile_1.id
    os_type         = var.kubernetes_pool01_os_type
    os_disk_size_gb = 30
  }

  // agent_pool_profile {
  //   name            = local.agent_pool_profile_2_name
  //   count           = var.kubernetes_pool02_min_count
  //   vm_size         = var.kubernetes_pool02_vm_size
  //   vnet_subnet_id  = azurerm_subnet.agent_pool_profile_2.id
  //   os_type         = var.kubernetes_pool02_os_type
  //   os_disk_size_gb = 30
  // }

  service_principal {
    client_id     = var.service_principal_app_id
    client_secret = var.service_principal_password
  }

  tags = merge(local.common_tags, {})
}

resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.kubernetes]

 triggers = {
   timestamp = timestamp()
 }

  provisioner "local-exec" {
    command = "rm -f kubeconfig"
  }

  provisioner "local-exec" {
    command = "az aks get-credentials --subscription ${var.subscription_id} --resource-group ${azurerm_kubernetes_cluster.kubernetes.resource_group_name} --name ${azurerm_kubernetes_cluster.kubernetes.name} -f kubeconfig"
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

// data "template_file" "autoscaler_config_pool02" {
//   template = file("autoscaler/cluster-autoscaler-containerservice.yaml.tpl")

//   vars = {
//     autoscaler_client_id           = base64encode(var.service_principal_app_id)
//     autoscaler_client_secret       = base64encode(var.service_principal_password)
//     autoscaler_resource_group      = base64encode(azurerm_kubernetes_cluster.kubernetes.resource_group_name)
//     autoscaler_subscription_id     = base64encode(var.subscription_id)
//     autoscaler_tenant_id           = base64encode(var.service_principal_tenant)
//     autoscaler_cluster_name        = base64encode(azurerm_kubernetes_cluster.kubernetes.name)
//     autoscaler_node_resource_group = base64encode(data.template_file.node_resource_group.rendered)
//     autoscaler_minimum             = var.kubernetes_pool02_min_count
//     autoscaler_maximum             = var.kubernetes_pool02_max_count
//     autoscaler_agentpool           = local.agent_pool_profile_2_name
//     autoscaler_version             = "v1.15.0"
//   }
// }

resource "null_resource" "kubernetes_autoscaler_config_pool01" {
  depends_on = [null_resource.kubeconfig]

  triggers = {
    autoscaler_config_changed = data.template_file.autoscaler_config_pool01.rendered
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=kubeconfig -f - <<EOF\n${data.template_file.autoscaler_config_pool01.rendered}\nEOF"
  }
}

// resource "null_resource" "kubernetes_autoscaler_config_pool02" {
//   depends_on = [null_resource.kubeconfig]

//   triggers = {
//     autoscaler_config_changed = data.template_file.autoscaler_config_pool02.rendered
//   }

//   provisioner "local-exec" {
//     command = "kubectl apply --kubeconfig=kubeconfig -f - <<EOF\n${data.template_file.autoscaler_config_pool02.rendered}\nEOF"
//   }
// }

### Helm

resource "kubernetes_service_account" "tiller" {
  depends_on = [null_resource.kubeconfig]
  metadata {
    annotations = merge(local.common_tags, {})

    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_rule" {
  depends_on = [kubernetes_service_account.tiller]

  metadata {
    annotations = merge(local.common_tags, {})

    name = "tiller-cluster-rule"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
    api_group = ""
  }
}

resource "null_resource" "helm_init" {
  depends_on = [
    kubernetes_cluster_role_binding.tiller_cluster_rule,
    null_resource.kubeconfig,
  ]

  provisioner "local-exec" {
    command = "helm --kubeconfig ${local.config_path} init --service-account tiller --automount-service-account-token --upgrade"
  }
}

### TLS (cert-manager + Let's Encrypt)

resource "null_resource" "create_cert_manager_crd" {
  depends_on = [null_resource.kubeconfig]

  triggers = {
    manifest_sha1 = sha1(file("files/cert-manager-crds.yaml"))
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f -<<EOF\n${file("files/cert-manager-crds.yaml")}\nEOF"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition challenges.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition issuers.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition orders.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition certificates.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} delete customresourcedefinition clusterissuers.certmanager.k8s.io --ignore-not-found"
  }
}

resource "kubernetes_secret" "service_principal_password" {
  depends_on = [null_resource.kubeconfig]

  metadata {
    name      = "service-principal-password"
    namespace = "cert-manager"
  }

  data = {
    password = var.service_principal_password
  }
}

resource "kubernetes_namespace" "cert_manager" {
  depends_on = [null_resource.kubeconfig]

  metadata {
    name = "cert-manager"
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert_manager" {
  depends_on = [null_resource.helm_init]

  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  chart      = "cert-manager"
  version    = "v0.6.0"
  repository = data.helm_repository.jetstack.metadata[0].name

  set {
    name  = "webhook.enabled"
    value = "false"
  }

  set {
    name  = "resources.requests.cpu"
    value = "10m"
  }

  set {
    name  = "resources.requests.memory"
    value = "32Mi"
  }
}

data "template_file" "letsencrypt_cluster_issuer_staging" {
  template = file("templates/letsencrypt-cluster-issuer.yaml.tpl")

  vars = {
    suffix                                = "-staging"
    letsencrypt_server                    = "https://acme-staging-v02.api.letsencrypt.org/directory"
    email                                 = "devops@sapience.net"
    service_principal_client_id           = var.service_principal_app_id
    service_principal_password_secret_ref = kubernetes_secret.service_principal_password.metadata[0].name
    dns_zone_name                         = "sapienceanalytics.com"
    resource_group_name                   = "Global"
    subscription_id                       = var.subscription_id
    service_pricincipal_tenant_id         = var.service_principal_tenant
  }
}

resource "null_resource" "letsencrypt_cluster_issuer_staging" {
  depends_on = [
    null_resource.kubeconfig,
    kubernetes_secret.service_principal_password,
  ]

  triggers = {
    template_changed = data.template_file.letsencrypt_cluster_issuer_staging.rendered
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.letsencrypt_cluster_issuer_staging.rendered}\nEOF"
  }
}

data "template_file" "letsencrypt_cluster_issuer_prod" {
  template = file("templates/letsencrypt-cluster-issuer.yaml.tpl")

  vars = {
    suffix                                = "-prod"
    letsencrypt_server                    = "https://acme-v02.api.letsencrypt.org/directory"
    email                                 = "devops@sapience.net"
    service_principal_client_id           = var.service_principal_app_id
    service_principal_password_secret_ref = kubernetes_secret.service_principal_password.metadata[0].name
    dns_zone_name                         = "sapienceanalytics.com"
    resource_group_name                   = "Global"
    subscription_id                       = var.subscription_id
    service_pricincipal_tenant_id         = var.service_principal_tenant
  }
}

resource "null_resource" "letsencrypt_cluster_issuer_prod" {
  depends_on = [
    null_resource.kubeconfig,
    kubernetes_secret.service_principal_password,
  ]

  triggers = {
    template_changed = data.template_file.letsencrypt_cluster_issuer_prod.rendered
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.letsencrypt_cluster_issuer_prod.rendered}\nEOF"
  }
}

