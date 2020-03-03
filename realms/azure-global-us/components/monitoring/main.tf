terraform {
  backend "azurerm" {
    key = "monitoring.tfstate"
  }
}

# See: https://akomljen.com/get-kubernetes-cluster-metrics-with-prometheus-in-5-minutes/

provider "kubernetes" {
  config_path = local.config_path
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace   = "monitoring"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Monitoring"
    },
  )
}

data "template_file" "custom_values" {
  template = file("custom-values.yaml.tpl")

  vars = {
    admin_password = var.monitoring_grafana_admin_password
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

resource "null_resource" "alertmanagers_crd" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/alertmanager.crd.yaml"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition alertmanagers.monitoring.coreos.com --ignore-not-found"
  }
}

resource "null_resource" "prometheuses_crd" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheus.crd.yaml"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition prometheuses.monitoring.coreos.com --ignore-not-found"
  }
}

resource "null_resource" "prometheusrules_crd" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/prometheusrule.crd.yaml"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition prometheusrules.monitoring.coreos.com --ignore-not-found"
  }
}

resource "null_resource" "servicemonitors_crd" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f https://raw.githubusercontent.com/coreos/prometheus-operator/master/example/prometheus-operator-crd/servicemonitor.crd.yaml"
  }
  provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition servicemonitors.monitoring.coreos.com --ignore-not-found"
  }
}

resource "helm_release" "prometheus" {
  depends_on = [
    null_resource.alertmanagers_crd,
    null_resource.prometheuses_crd,
    null_resource.prometheusrules_crd,
    null_resource.servicemonitors_crd,
  ]

  name      = "prometheus"
  namespace = local.namespace
  chart     = "stable/prometheus-operator"
  values = [
    data.template_file.custom_values.rendered,
  ]

  set {
    name  = "prometheusOperator.createCustomResource"
    value = "false"
  }
}

