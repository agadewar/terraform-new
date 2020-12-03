terraform {
  backend "azurerm" {
    key = "red/logging.tfstate"
  }
}

# See: https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes/

provider "kubernetes" {
  config_path = local.config_path
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  # #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  # service_account = "tiller"
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace   = "logging"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Logging"
    },
  )
}

data "template_file" "custom_values" {
  template = file("custom-values.yaml.tpl")
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

data "helm_repository" "akomljen_charts" {
  name = "akomljen-charts"
  url  = "https://raw.githubusercontent.com/komljen/helm-charts/master/charts/"
}

/*resource "helm_release" "es_operator" {
  name       = "es-operator"
  namespace  = local.namespace
  repository = data.helm_repository.akomljen_charts.name
  chart      = "akomljen-charts/elasticsearch-operator"
}*/

resource "helm_release" "efk" {
  #depends_on = [helm_release.es_operator]

  name       = "efk"
  namespace  = local.namespace
  repository = data.helm_repository.akomljen_charts.name
  #chart      = "akomljen-charts/efk"
  chart      = "stable/elastic-stack"
  values = [
    data.template_file.custom_values.rendered,
  ]

  #set {
  #  name  = "elasticsearch.spec.data-volume-size"
  #  value = "200Gi"
  #}

  set {
    name  = "fluent-bit.image.fluent_bit.tag"
    value = "1.1.1-debug"
  }

  // see: https://github.com/helm/charts/blob/master/stable/fluent-bit/values.yaml
  set {
    name  = "fluent-bit.rawConfig"
    value = <<EOF
@INCLUDE fluent-bit-service.conf
@INCLUDE fluent-bit-input.conf
@INCLUDE fluent-bit-filter.conf
    Merge_Log_Key       app
    Keep_Log            On
[FILTER]
    Name                nest
    Match               *
    Operation           lift
    Nested_under        kubernetes
[FILTER]
    Name                grep
    Match               *
    Exclude             namespace_name   kubernetes-dashboard
@INCLUDE fluent-bit-output.conf
EOF
  }
}
