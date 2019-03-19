terraform {
  backend "azurerm" {
    key = "sapience.environment.sandbox.ambassador.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

provider "helm" {
  kubernetes {
    config_path = "${local.config_path}"
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

provider "kubernetes" {
    config_path = "${local.config_path}"
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "${var.backend_container_name}"
    key                  = "sapience.environment.${var.environment}.dns.terraform.tfstate"
  }
}

locals {
  config_path = "../../../realms/${var.realm}/kubernetes/kubeconfig"
  namespace = "${var.environment}"
  
  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Ambassador"
    )
  )}"
}

# See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
resource "null_resource" "ambassador_rbac" {
  triggers = {
    manifest_sha1 = "${sha1("${file("files/ambassador-rbac.yaml")}")}"
    timestamp = "${timestamp()}"   # DELETE ME
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f -<<EOF\n${file("files/ambassador-rbac.yaml")}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#2-defining-the-ambassador-service
resource "kubernetes_service" "ambassador" {
  metadata {
    name = "ambassador"
    namespace = "${local.namespace}"

    annotations {
      "getambassador.io/config" = <<EOF
---
apiVersion: ambassador/v1
kind: Module
name: tls
config:
  server:
    enabled: True
    # redirect_cleartext_from: 80
    secret: ambassador-certs
EOF
    }
  }

  spec {
    selector {
      service = "ambassador"
    }

    port {
      name = "http"
      port = 80
    }

    port {
      name = "https"
      port = 443
    }

    # See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
    # Note: Due to issue above, use "null_resource.patch_ambassador_service" to patch the "externalTrafficPolicy" property
    # external_traffic_policy = "Local"
    
    type = "LoadBalancer"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#2-defining-the-ambassador-service
# See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
resource "null_resource" "patch_ambassador_service" {
  depends_on = [ "kubernetes_service.ambassador" ]

  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl patch --kubeconfig=${local.config_path} svc ambassador -n ${local.namespace} -p '{\"spec\":{\"externalTrafficPolicy\":\"Local\"}}'"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#5-adding-a-service
resource "kubernetes_service" "api" {
  metadata {
    name = "api"
    namespace = "${local.namespace}"
    annotations {
      "getambassador.io/config" = <<EOF
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_device_service_mapping
prefix: /device/
service: canopy-device-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_hierarchy_service_mapping
prefix: /hierarchy/
service: canopy-hierarchy-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_user_service_mapping
prefix: /user/
service: canopy-user-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_leaf_broker_mapping
prefix: /leafbroker/
service: eventpipeline-leaf-broker
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_service_mapping
prefix: /eventpipeline/
service: eventpipeline-service
EOF
    }
  }

  spec {
    port {
      name = "http"
      port = 80
    }
  }
}

resource "azurerm_dns_a_record" "api" {
  name                = "api"
  zone_name           = "${data.terraform_remote_state.dns.zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${kubernetes_service.ambassador.load_balancer_ingress.0.ip}" ]
}

# See: https://www.getambassador.io/user-guide/cert-manager
# See: https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
resource "null_resource" "create_cert_manager_crd" {
  triggers {
    manifest_sha1 = "${sha1("${file("files/cert-manager-crds.yaml")}")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f -<<EOF\n${file("files/cert-manager-crds.yaml")}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition challenges.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition issuers.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition orders.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition certificates.certmanager.k8s.io --ignore-not-found"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition clusterissuers.certmanager.k8s.io --ignore-not-found"
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url  = "https://charts.jetstack.io"
}

# See: https://hub.helm.sh/charts/jetstack/cert-manager/v0.6.0
resource "helm_release" "cert_manager" {
  depends_on = [ "null_resource.create_cert_manager_crd" ]

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

# resource "null_resource" "delete_cert_manager_crd" {
#   # cleanup CustomResourceDefinition(s) created by "helm_release.cert_manager"

#   # depends_on = [ "helm_release.cert_manager" ]

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition certificates.certmanager.k8s.io --ignore-not-found"
#   }

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete customresourcedefinition clusterissuers.certmanager.k8s.io --ignore-not-found"
#   }
# }

# See: https://www.getambassador.io/user-guide/cert-manager
data "template_file" "letsencrypt_cluster_issuer" {
  template = "${file("templates/letsencrypt-cluster-issuer.yaml.tpl")}"

  vars {
     email = "${var.ambassador_letsencrypt_email}"
  }
}

resource "null_resource" "letsencrypt_cluster_issuer" {
  depends_on = ["helm_release.cert_manager"]

  triggers {
    template_changed = "${data.template_file.letsencrypt_cluster_issuer.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_cluster_issuer.rendered}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/cert-manager
data "template_file" "letsencrypt_certificate" {
  template = "${file("templates/letsencrypt-certificate.yaml.tpl")}"

  vars {
     namespace = "${local.namespace}"
  }
}

resource "null_resource" "letsencrypt_certificate" {
  depends_on = ["helm_release.cert_manager"]

  triggers {
    template_changed = "${data.template_file.letsencrypt_certificate.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_certificate.rendered}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/cert-manager
data "template_file" "letsencrypt_acme_challenge_service" {
  template = "${file("templates/letsencrypt-acme-challenge-service.yaml.tpl")}"

  vars {
    acme_http_domain = "${var.ambassador_letsencrypt_acme_http_domain}"
    acme_http_token  = "${var.ambassador_letsencrypt_acme_http_token}"
  }
}

resource "null_resource" "letsencrypt_acme_challenge_service" {
  depends_on = ["helm_release.cert_manager"]

  triggers {
    template_changed = "${data.template_file.letsencrypt_acme_challenge_service.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_acme_challenge_service.rendered}\nEOF"
  }
}

# # resource "kubernetes_deployment" "statsd_sink" {
# #   metadata {
# #     # creation_timestamp = null
# #     name = "statsd-sink"
# #     namespace = "${local.namespace}"
# #   }

# #   spec {
# #     replicas = 1

# #     selector {
# #       match_labels {
# #         service = "statsd-sink"
# #       }
# #     }

# #     template {
# #       metadata {
# #         labels {
# #           service = "statsd-sink"
# #         }
# #       }

# #       spec {
# #         container {
# #           name = "statsd-sink"
# #           image = "prom/statsd-exporter:v0.8.1"

# #           resources{
# #             requests{
# #               cpu    = "100m"
# #               memory = "25Mi"
# #             }
# #           }
# #         }

# #         restart_policy = "Always"
# #       }
# #     }
# #   }
# # }

# # resource "kubernetes_service" "statsd-sink" {
# #   metadata {
# #     name = "statsd-sink"
# #     namespace = "${local.namespace}"

# #     labels {
# #       "service" = "statsd-sink"
# #     }

# #     annotations {
# #       # "prometheus.io/probe" = "true"
# #       # "prometheus.io/scrape" = "true"
# #       # "prometheus.io/scheme" = "http"
# #       # "prometheus.io/path" = "/metrics"
# #     }
# #   }

# #   spec {
# #     port {
# #       protocol = "UDP"
# #       port = 8125
# #       name = "statsd-sink"
# #     }

# #     port {
# #       protocol = "TCP"
# #       port = 9102
# #       name = "prometheus-metrics"
# #     }

# #     selector {
# #       "service" = "statsd-sink"
# #     }
# #   }
# # }

# # # See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
# # resource "null_resource" "statsd_sink" {
# #   triggers = {
# #     manifest_sha1 = "${sha1("${file("files/statsd-sink.yaml")}")}"
# #     timestamp = "${timestamp()}"   # DELETE ME
# #   }

# #   provisioner "local-exec" {
# #     command = "kubectl apply --kubeconfig=${local.config_path} -n monitoring -f -<<EOF\n${file("files/statsd-sink.yaml")}\nEOF"
# #   }
# # }

# # # See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
# # resource "null_resource" "service_monitor" {
# #   triggers = {
# #     manifest_sha1 = "${sha1("${file("files/statsd-sink.yaml")}")}"
# #     timestamp = "${timestamp()}"   # DELETE ME
# #   }

# #   provisioner "local-exec" {
# #     command = "kubectl apply --kubeconfig=${local.config_path} -n dev -f -<<EOF\n${file("files/statsd-sink.yaml")}\nEOF"
# #   }
# # }