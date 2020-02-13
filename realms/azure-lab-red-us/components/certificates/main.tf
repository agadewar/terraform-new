terraform {
  backend "azurerm" {
    key = "red/certificates.tfstate"
  }
}

provider "helm" {
  version = "0.10.4"
  kubernetes {
    config_path = local.config_path
  }

  service_account = "tiller"
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

locals {
  config_path = "../kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Certificates"
    },
  )
}

resource "null_resource" "create_cert_manager_crd" {
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

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret" "service_principal_password" {
  metadata {
    name      = "service-principal-password"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }

  data = {
    password = var.service_principal_password
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  chart      = "cert-manager"
  version    = "v0.8.1"
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
    resource_group_name                   = "global-us"
    subscription_id                       = var.global_subscription_id
    service_pricincipal_tenant_id         = var.service_principal_tenant
  }
}

resource "null_resource" "letsencrypt_cluster_issuer_staging" {
  depends_on = [ kubernetes_secret.service_principal_password ]

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
    resource_group_name                   = "global-us"
    subscription_id                       = var.global_subscription_id
    service_pricincipal_tenant_id         = var.service_principal_tenant
  }
}

resource "null_resource" "letsencrypt_cluster_issuer_prod" {
  depends_on = [ kubernetes_secret.service_principal_password ]

  triggers = {
    template_changed = data.template_file.letsencrypt_cluster_issuer_prod.rendered
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -f - <<EOF\n${data.template_file.letsencrypt_cluster_issuer_prod.rendered}\nEOF"
  }
}
