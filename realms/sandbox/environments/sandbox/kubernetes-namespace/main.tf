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
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.realm.${var.realm}.kubernetes.terraform.tfstate"
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
    data = "${file(".local/default_token_secret_name.out")}"
    dummy = "${format(null_resource.default_token_secret_name.id)}"
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
      "sapience.net/name" = "azure-egress"
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

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

# See: https://hub.helm.sh/charts/jetstack/cert-manager/v0.6.0
resource "helm_release" "cert_manager" {
  depends_on = [ "kubernetes_namespace.namespace" ]

  name       = "cert-manager"
  namespace  = "${local.namespace}"
  chart      = "cert-manager"
  version    = "v0.6.0"
  repository = "${data.helm_repository.jetstack.metadata.0.name}"
  
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

# https://github.com/fbeltrao/aks-letsencrypt/blob/master/setup-wildcard-certificates-with-azure-dns.md
resource "kubernetes_secret" "service_principal_password" {
  metadata {
    name = "service-principal-password"
    namespace = "${local.namespace}"
  }

  data {
    password = "${var.service_principal_password}"
  }
}

# https://github.com/fbeltrao/aks-letsencrypt/blob/master/setup-wildcard-certificates-with-azure-dns.md
data "template_file" "letsencrypt_issuer_staging" {
  template = "${file("templates/letsencrypt-issuer.yaml.tpl")}"

  vars {
    suffix = "-staging"
    letsencrypt_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    email = "${var.letsencrypt_cluster_issuer_email}"
    service_principal_client_id = "${var.service_principal_app_id}"
    service_principal_password_secret_ref = "${kubernetes_secret.service_principal_password.metadata.0.name}"
    dns_zone_name = "${var.environment}.sapience.net"
    resource_group_name = "${var.resource_group_name}"
    subscription_id = "${var.subscription_id}"
    service_pricincipal_tenant_id = "${var.service_principal_tenant}"
  }
}

resource "null_resource" "letsencrypt_issuer_staging" {
  depends_on = [ "helm_release.cert_manager" ]

  triggers {
    template_changed = "${data.template_file.letsencrypt_issuer_staging.rendered}"
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_issuer_staging.rendered}\nEOF"
  }
}

# https://github.com/fbeltrao/aks-letsencrypt/blob/master/setup-wildcard-certificates-with-azure-dns.md
data "template_file" "letsencrypt_issuer_prod" {
  template = "${file("templates/letsencrypt-issuer.yaml.tpl")}"

  vars {
    suffix = "-prod"
    letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"
    email = "${var.letsencrypt_cluster_issuer_email}"
    service_principal_client_id = "${var.service_principal_app_id}"
    service_principal_password_secret_ref = "${kubernetes_secret.service_principal_password.metadata.0.name}"
    dns_zone_name = "${var.environment}.sapience.net"
    resource_group_name = "${var.resource_group_name}"
    subscription_id = "${var.subscription_id}"
    service_pricincipal_tenant_id = "${var.service_principal_tenant}"
  }
}

resource "null_resource" "letsencrypt_issuer_prod" {
  depends_on = [ "helm_release.cert_manager" ]

  triggers {
    template_changed = "${data.template_file.letsencrypt_issuer_prod.rendered}"
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_issuer_prod.rendered}\nEOF"
  }
}
