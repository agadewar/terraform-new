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

data "terraform_remote_state" "spinnaker_storage" {
  backend = "azurerm"

  config {
    access_key            = "${var.backend_access_key}"
    storage_account_name  = "${var.backend_storage_account_name}"
	  container_name        = "realm-${var.realm}"
    key                   = "spinnaker-storage.tfstate"
  }
}

data "template_file" "custom_values" {
  template = "${file("custom-values.yaml.tpl")}"

  vars {
    storageAccountName = "${data.terraform_remote_state.spinnaker_storage.spinnaker_storage_account_name}"
    accessKey = "${data.terraform_remote_state.spinnaker_storage.spinnaker_storage_account_access_key}"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = "${local.namespace}"
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

resource "helm_release" "spinnaker" {
  # depends_on = [ "null_resource.alertmanagers_crd", "null_resource.prometheuses_crd", "null_resource.prometheusrules_crd", "null_resource.servicemonitors_crd" ]

  name       = "spinnaker"
  namespace  = "${local.namespace}"
  chart      = "stable/spinnaker"
  values = [
    "${data.template_file.custom_values.rendered}"
  ]

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
