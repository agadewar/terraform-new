terraform {
  backend "azurerm" {
    key = "spinnaker.tfstate"
  }
}

# See: https://akomljen.com/get-kubernetes-cluster-metrics-with-prometheus-in-5-minutes/

provider "kubernetes" {
    config_path = "${local.config_path}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

locals {
  config_path = "../kubernetes/kubeconfig"
  namespace = "spinnaker"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Spinnaker"
    )
  )}"
}

data "terraform_remote_state" "storage_account" {
  backend = "azurerm"

  config {
    access_key            = "${var.backend_access_key}"
    storage_account_name  = "${var.backend_storage_account_name}"
	  container_name        = "realm-${var.realm}"
    key                   = "storage-account.tfstate"
  }
}

data "template_file" "custom_values" {
  template = "${file("templates/custom-values.yaml.tpl")}"

  vars {
    realm                  = "${var.realm}"
    storageAccountName     = "${data.terraform_remote_state.storage_account.storage_account_name}"
    accessKey              = "${data.terraform_remote_state.storage_account.storage_account_access_key}"
    whitelist-source-range = "${join(", ", var.spinnaker_source_ranges_allowed)}"
    kubeconfig-contexts    = "${indent(2, join("\n", formatlist("- %s", var.spinnaker_kubeconfig_contexts)))}"
    acr-address            = "${var.sapience_container_registry_hostname}"
    acr-username           = "${var.sapience_container_registry_username}"
    acr-password           = "${var.sapience_container_registry_password}"
    acr-email              = "${var.devops_email}"
  }
}

resource "kubernetes_namespace" "spinnaker" {
  metadata {
    name = "${local.namespace}"
  }
}

resource "kubernetes_secret" "kubeconfig" {
  metadata {
    name      = "kubeconfig"
    namespace = "${local.namespace}"
  }

  data {
    # don't use "local.config_path" here, as it may need to be a kubeconfig file comprised of multiple environments; this secret
    # is used by the spinnaker helm chart to make Spinnaker aware of the K8S clusters it should be aware of
    config = "${file("${var.kubeconfig}")}"
  }
}

# resource "null_resource" "alertmanagers_crd" {

#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/alertmanager.crd.yaml"
#   }

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition alertmanagers.monitoring.coreos.com --ignore-not-found"
#   }
# }

# resource "null_resource" "prometheuses_crd" {

#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheus.crd.yaml"
#   }

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition prometheuses.monitoring.coreos.com --ignore-not-found"
#   }
# }

# resource "null_resource" "prometheusrules_crd" {

#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheusrule.crd.yaml"
#   }

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition prometheusrules.monitoring.coreos.com --ignore-not-found"
#   }
# }

# resource "null_resource" "servicemonitors_crd" {

#   provisioner "local-exec" {
#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/servicemonitor.crd.yaml"
#   }
#   provisioner "local-exec" {
#     when = "destroy"

#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition servicemonitors.monitoring.coreos.com --ignore-not-found"
#   }
# }

resource "kubernetes_secret" "service_principal_password" {
  metadata {
    name = "service-principal-password"
    namespace = "${local.namespace}"
  }

  data {
    password = "${var.service_principal_password}"
  }
}

data "template_file" "letsencrypt_issuer_staging" {
  template = "${file("templates/letsencrypt-issuer.yaml.tpl")}"

  vars {
    suffix = "-staging"
    letsencrypt_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
    email = "devops@sapience.net"   # TODO !!! Normally, this would come from var.letsencrypt_cluster_issuer_email of the environment tfvars; but this is a realm component, so need to figure this out
    service_principal_client_id = "${var.service_principal_app_id}"
    service_principal_password_secret_ref = "${kubernetes_secret.service_principal_password.metadata.0.name}"
    dns_zone_name = "${var.realm}.sapience.net"   #TODO !!! Normally, this would be var.environment (as the DNS zones are environment-specific); but, this is a realm component, so need to figure this out
    resource_group_name = "${var.resource_group_name}"
    subscription_id = "${var.subscription_id}"
    service_pricincipal_tenant_id = "${var.service_principal_tenant}"
  }
}

resource "null_resource" "letsencrypt_issuer_staging" {
  # depends_on = [ "helm_release.cert_manager" ]

  triggers {
    template_changed = "${data.template_file.letsencrypt_issuer_staging.rendered}"
    # timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_issuer_staging.rendered}\nEOF"
  }
}

data "template_file" "letsencrypt_issuer_prod" {
  template = "${file("templates/letsencrypt-issuer.yaml.tpl")}"

  vars {
    suffix = "-prod"
    letsencrypt_server = "https://acme-v02.api.letsencrypt.org/directory"
    email = "devops@sapience.net"   # TODO !!! Normally, this would come from var.letsencrypt_cluster_issuer_email of the environment tfvars; but this is a realm component, so need to figure this out
    service_principal_client_id = "${var.service_principal_app_id}"
    service_principal_password_secret_ref = "${kubernetes_secret.service_principal_password.metadata.0.name}"
    dns_zone_name = "${var.realm}.sapience.net"   #TODO !!! Normally, this would be var.environment (as the DNS zones are environment-specific); but, this is a realm component, so need to figure this out
    resource_group_name = "${var.resource_group_name}"
    subscription_id = "${var.subscription_id}"
    service_pricincipal_tenant_id = "${var.service_principal_tenant}"
  }
}

resource "null_resource" "letsencrypt_issuer_prod" {
  # depends_on = [ "helm_release.cert_manager" ]

  triggers {
    template_changed = "${data.template_file.letsencrypt_issuer_prod.rendered}"
    # timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_issuer_prod.rendered}\nEOF"
  }
}

data "template_file" "letsencrypt_certificate" {
  template = "${file("templates/letsencrypt-certificate.yaml.tpl")}"

  vars {
     namespace = "${local.namespace}"
     realm     = "${var.realm}"
  }
}

resource "null_resource" "letsencrypt_certificate" {
  triggers {
    template_changed = "${data.template_file.letsencrypt_certificate.rendered}"
    # timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_certificate.rendered}\nEOF"
  }
}

resource "helm_release" "nginx_ingress" {
  depends_on = [ "kubernetes_namespace.spinnaker" ]

  name      = "nginx-ingress"
  namespace = "${local.namespace}"
  chart     = "stable/nginx-ingress"

  set {
    name  = "controller.replicaCount"
    value = "1"
  }

  # See: https://docs.microsoft.com/en-us/azure/aks/ingress-tls
  # set {
  #   name  = "controller.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #   value = "linux"
  # }

  # set {
  #   name  = "defaultBackend.nodeSelector.\"beta\\.kubernetes\\.io/os\""
  #   value = "linux"
  # }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}

resource "helm_release" "spinnaker" {
  depends_on = [ "kubernetes_namespace.spinnaker", "helm_release.nginx_ingress" ]

  name       = "spinnaker"
  namespace  = "${local.namespace}"
  chart      = "stable/spinnaker"
  values = [
    "${data.template_file.custom_values.rendered}"
  ]

  timeout = 600

  # set {
  #   name  = "redis.enabled"
  #   value = "false"
  # }

  # set {
  #   name  = "azs.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "azs.storageAccountName"
  #   value = ""
  # }

  # set {
  #   name  = "azs.accessKey"
  #   value = ""
  # }

  # set {
  #   name  = "azs.containerName"
  #   value = "spinnaker"
  # }
}
