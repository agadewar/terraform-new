terraform {
  backend "azurerm" {
    key = "sonarqube.tfstate"
  }
}

# See: https://akomljen.com/get-kubernetes-logs-with-efk-stack-in-5-minutes/
provider "azurerm" {
  version = "1.31.0"

  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

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
  config_path = "../kubernetes/kubeconfig"
  namespace   = "sonarqube"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "SonarQube"
    },
  )
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config = {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "dns.tfstate"
  }
}

data "terraform_remote_state" "ingress-controller" {
  backend = "azurerm"

  config = {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "ingress-controller.tfstate"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

// data "helm_repository" "akomljen_charts" {
//   name = "akomljen-charts"
//   url  = "https://raw.githubusercontent.com/komljen/helm-charts/master/charts/"
// }

// resource "helm_release" "es_operator" {
//   name       = "es-operator"
//   namespace  = local.namespace
//   repository = data.helm_repository.akomljen_charts.name
//   chart      = "akomljen-charts/elasticsearch-operator"
// }

// resource "helm_release" "efk" {
//   depends_on = [helm_release.es_operator]

//   name       = "efk"
//   namespace  = local.namespace
//   repository = data.helm_repository.akomljen_charts.name
//   chart      = "akomljen-charts/efk"
// }

resource "helm_release" "sonarqube" {
  depends_on = [ "kubernetes_namespace.namespace"]

  name       = "sonarqube"
  namespace  = "${local.namespace}"
  chart      = "stable/sonarqube"

  timeout = 600

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  # set {
  #   name  = "ingress.enabled"
  #   value = "true"
  # }

  # set {
  #   name  = "ingress.hosts[0].name"
  #   value = "sonarqube.${var.realm}.sapienceanalytics.com"
  # }

  # set {
  #   name  = "ingress.hosts[0].path"
  #   value = "/"
  # }

  # set {
  #   # name  = "ingress.annotations[0].ingress.kubernetes.io/ssl-redirect"
  #   # name  = "ingress.annotations[0].\"nginx\\.ingress\\.kubernetes\\.io/ssl-redirect\""
  #   name  = "ingress.annotations.\"nginx\\.ingress\\.kubernetes\\.io/ssl-redirect\""
  #   // name = "ingress.annotations[0].nginx.ingress.kubernetes.io/ssl-redirect"
  #   // name  = "ingress.annotations.ingress.\"kubernetes\\.io/ssl-redirect\""
  #   value = "true"
  #   # name = "ingress.annotations"
  #   # value = { 
  #   #   "ingress.annotations.ingress.kubernetes.io/ssl-redirect" : "true  "
  #   # }
  # }

  # set {
  #   name  = "ingress.annotations.\"nginx\\.ingress\\.kubernetes\\.io/ingress.class\""
  #   value = "nginx"
  # }

  # set {
  #   name = "ingress.annotations"
  #   value = map("nginx.ingress.kubernetes.io/ssl-redirect", "true", "nginx.ingress.kubernetes.io/ingress.class", "nginx")
  # }

  values = [<<EOF
ingress:
  enabled: true
  annotations:
    certmanager.k8s.io/acme-challenge-type             : dns01
    certmanager.k8s.io/acme-dns01-provider             : azure-dns
    certmanager.k8s.io/cluster-issuer                  : letsencrypt-prod
    kubernetes.io/ingress.class                        : nginx
    kubernetes.io/tls-acme                             : true
    nginx.ingress.kubernetes.io/ssl-redirect           : true
    nginx.ingress.kubernetes.io/whitelist-source-range : ${join(", ", var.sonarqube_source_ranges_allowed)}
  hosts:
    - path: /
      name: sonarqube.${var.realm}.sapienceanalytics.com
EOF
  ]

  // set {
  //   name  = "ingress.annotations.kubernetes.io/tls-acme"
  //   value = "true"
  // }

  # set {
  #   # name  = "ingress.annotations[0].nginx.ingress.kubernetes.io/whitelist-source-range"
  #   name  = "ingress.annotations.\"nginx\\.ingress\\.kubernetes\\.io/whitelist-source-range\""
  #   # value = join(", ", var.sonarqube_source_ranges_allowed)
  #   value = "50.20.0.62/32, 24.99.117.169/32, 162.236.22.89/32, 24.125.218.36/32, 47.187.167.223/32, 47.187.172.225/32, 47.190.73.52/32, 209.170.229.238/32, 69.168.39.211/32"
  # }

  // set {
  //   name  = "ingress.annotations.certmanager.k8s.io/acme-challenge-type"
  //   value = "dns01"
  // }

  // set {
  //   name  = "ingress.annotations.certmanager.k8s.io/acme-dns01-provider"
  //   value = "azure-dns"
  // }

  // set {
  //   name  = "ingress.annotations.certmanager.k8s.io/cluster-issuer"
  //   value = "letsencrypt-prod"
  // }

  // set {
  //   name  = "ingress.tls.secretname"
  //   value = "sonarqube-certs"
  // }

  // set {
  //   name  = "ingress.tls.hosts[0]"
  //   // value = "sonarqube.${var.realm}.sapienceanalytics.com\nsonarqube.sapienceanalytics.com"
  //   value = "sonarqube.${var.realm}.sapienceanalytics.com"
  // }
}

resource "azurerm_dns_a_record" "sonarqube" {
  name                = "sonarqube.${var.realm}"
  zone_name           = "${data.terraform_remote_state.dns.outputs.sapienceanalytics_public_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip}" ]
}
