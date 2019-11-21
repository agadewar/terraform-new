terraform {
  backend "azurerm" {
    key = "sonarqube.tfstate"
  }
}

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
  config_path = "../kubernetes/.local/kubeconfig"
  namespace   = "consul"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Consul"
    },
  )
}

data "template_file" "custom_values" {
  template = file("custom-values.yaml.tpl")
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config = {
    access_key           = "${var.realm_backend_access_key}"
    storage_account_name = "${var.realm_backend_storage_account_name}"
	  container_name       = "${var.realm_backend_container_name}"
    key                  = "dns.tfstate"
  }
}

data "terraform_remote_state" "ingress-controller" {
  backend = "azurerm"

  config = {
    access_key           = "${var.realm_backend_access_key}"
    storage_account_name = "${var.realm_backend_storage_account_name}"
	  container_name       = "${var.realm_backend_container_name}"
    key                  = "ingress-controller.tfstate"
  }
}

# See: https://github.com/helm/charts/tree/master/stable/sonarqube
resource "helm_release" "consul" {
  name      = "consul"
  namespace = "${local.namespace}"
  chart     = "stable/consul"
  values    = [
    data.template_file.custom_values.rendered,
  ]
  timeout = 600

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

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
    nginx.ingress.kubernetes.io/whitelist-source-range : ${join(", ", concat([data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip], var.consul_source_ranges_allowed))}
  hosts:
    - name: consul.sapienceanalytics.com
      path: /
    - name: consul.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com
      path: /
  tls:
    - secretName: consul-certs
      hosts: 
        - consul.sapienceanalytics.com
        - consul.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com
persistence:
  enabled: true
  existingClaim: consul-home
EOF
  ]

}

resource "azurerm_dns_a_record" "consul" {
  name                = "consul.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "${data.terraform_remote_state.dns.outputs.sapienceanalytics_public_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip}" ]
} 

/*     values = [<<EOF
ingress:
  enabled: true
  annotations:
    certmanager.k8s.io/acme-challenge-type             : dns01
    certmanager.k8s.io/acme-dns01-provider             : azure-dns
    certmanager.k8s.io/cluster-issuer                  : letsencrypt-prod
    kubernetes.io/ingress.class                        : nginx
    kubernetes.io/tls-acme                             : true
    nginx.ingress.kubernetes.io/ssl-redirect           : true
    nginx.ingress.kubernetes.io/whitelist-source-range : ${join(", ", concat([data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip], var.consul_source_ranges_allowed))}
  hosts:
    - name: consul.sapienceanalytics.com
      path: /
    - name: sonarqube.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com
      path: /
  tls:
    - secretName: sonarqube-certs
      hosts: 
        - sonarqube.sapienceanalytics.com
        - sonarqube.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com
persistence:
  enabled: true
  existingClaim: consul-home
postgresql:
  persistence:
    enabled: true
    existingClaim: sonarqube-postgresql
EOF
  ] */

/* resource "azurerm_dns_a_record" "sonarqube" {
  name                = "sonarqube.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "${data.terraform_remote_state.dns.outputs.sapienceanalytics_public_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip}" ]
} */
