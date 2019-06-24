terraform {
  backend "azurerm" {
    key = "ambassador.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${var.subscription_id}"
}

provider "kubernetes" {
    config_path = "${local.config_path}"
}

locals {
  config_path = "../../../components/kubernetes/kubeconfig"
  namespace = "${var.environment}"
  
  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Ambassador"
    )
  )}"
}

data "terraform_remote_state" "ingress_controller" {
  backend = "azurerm"
  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
	  container_name       = "realm-${var.realm}"
    key                  = "ingress-controller.tfstate"
  }
}

resource "kubernetes_ingress" "api" {
  metadata {
    name = "api"
    namespace = "${local.namespace}"

    annotations = {
      "certmanager.k8s.io/acme-challenge-type"             = "dns01"  
      "certmanager.k8s.io/acme-dns01-provider"             = "azure-dns"
      "certmanager.k8s.io/cluster-issuer"                  = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect"                 = "true"
      "kubernetes.io/ingress.class"                        = "nginx"
      "kubernetes.io/tls-acme"                             = "true"
    }
  }

  spec {
    rule {
      host = "api.${var.environment}.${var.realm}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "ambassador"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    rule {
      host = "api.${var.environment}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "ambassador"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [ 
        "api.${var.environment}.${var.realm}.sapienceanalytics.com",
        "api.${var.environment}.sapienceanalytics.com"
      ]
      secret_name = "ambassador-certs"
    }
  }
}

data "template_file" "ambassador-rbac" {
  template = "${file("templates/ambassador-rbac.yaml.tpl")}"

  vars {
     replicas = "${var.ambassador_rbac_replicas}"
  }
}

resource "null_resource" "ambassador_rbac" {
  triggers = {
    template_changed = "${data.template_file.ambassador-rbac.rendered}"
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.ambassador-rbac.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = "destroy"

    command = "kubectl delete --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.ambassador-rbac.rendered}\nEOF"
  }  
}

resource "kubernetes_service" "ambassador" {
  metadata {
    name = "ambassador"
    namespace = "${local.namespace}"

#     annotations {
#       "getambassador.io/config" = <<EOF
# ---
# apiVersion: ambassador/v1
# kind: Module
# name: tls
# config:
#   server:
#     enabled: True
#     redirect_cleartext_from: 80
#     secret: ambassador-certs
# EOF
#     }
  }

  spec {
    selector {
      service = "ambassador"
    }

    port {
      name = "http"
      port = 80
      # target_port = 80
    }

    # port {
    #   name = "https"
    #   port = 443
    # }

    # See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
    # Note: Due to issue above, use "null_resource.patch_ambassador_service" to patch the "externalTrafficPolicy" property
    # external_traffic_policy = "Local"
    
    type = "ClusterIP"
  }
}

# # See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
# resource "null_resource" "patch_ambassador_service" {
#   depends_on = [ "kubernetes_service.ambassador" ]

#   provisioner "local-exec" {
#     command = "kubectl patch --kubeconfig=${local.config_path} svc ambassador -n ${local.namespace} -p '{\"spec\":{\"externalTrafficPolicy\":\"Local\"}}'"
#   }
# }

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
  name                = "api.${var.environment}.${var.realm}"
  zone_name           = "sapienceanalytics.com"
  resource_group_name = "global"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress_controller.nginx_ingress_controller_ip}" ]
}

# resource "kubernetes_deployment" "statsd_sink" {
#   metadata {
#     # creation_timestamp = null
#     name = "statsd-sink"
#     namespace = "${local.namespace}"
#   }

#   spec {
#     replicas = 1

#     selector {
#       match_labels {
#         service = "statsd-sink"
#       }
#     }

#     template {
#       metadata {
#         labels {
#           service = "statsd-sink"
#         }
#       }

#       spec {
#         container {
#           name = "statsd-sink"
#           image = "prom/statsd-exporter:v0.8.1"

#           resources{
#             requests{
#               cpu    = "100m"
#               memory = "25Mi"
#             }
#           }
#         }

#         restart_policy = "Always"
#       }
#     }
#   }
# }

# resource "kubernetes_service" "statsd-sink" {
#   metadata {
#     name = "statsd-sink"
#     namespace = "${local.namespace}"

#     labels {
#       "service" = "statsd-sink"
#     }

#     annotations {
#       # "prometheus.io/probe" = "true"
#       # "prometheus.io/scrape" = "true"
#       # "prometheus.io/scheme" = "http"
#       # "prometheus.io/path" = "/metrics"
#     }
#   }

#   spec {
#     port {
#       protocol = "UDP"
#       port = 8125
#       name = "statsd-sink"
#     }

#     port {
#       protocol = "TCP"
#       port = 9102
#       name = "prometheus-metrics"
#     }

#     selector {
#       "service" = "statsd-sink"
#     }
#   }
# }

# # See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
# resource "null_resource" "statsd_sink" {
#   triggers = {
#     manifest_sha1 = "${sha1("${file("files/statsd-sink.yaml")}")}"
#     timestamp = "${timestamp()}"   # DELETE ME
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply --kubeconfig=${local.config_path} -n monitoring -f -<<EOF\n${file("files/statsd-sink.yaml")}\nEOF"
#   }
# }

# # See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
# resource "null_resource" "service_monitor" {
#   triggers = {
#     manifest_sha1 = "${sha1("${file("files/statsd-sink.yaml")}")}"
#     timestamp = "${timestamp()}"   # DELETE ME
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply --kubeconfig=${local.config_path} -n dev -f -<<EOF\n${file("files/statsd-sink.yaml")}\nEOF"
#   }
# }

# # https://github.com/fbeltrao/aks-letsencrypt/blob/master/setup-wildcard-certificates-with-azure-dns.md
# data "template_file" "letsencrypt_certificate" {
#   template = "${file("templates/letsencrypt-certificate.yaml.tpl")}"

#   vars {
#      realm       = "${var.realm}"
#      environment = "${var.environment}"
#   }
# }

# resource "null_resource" "letsencrypt_certificate" {
#   triggers {
#     template_changed = "${data.template_file.letsencrypt_certificate.rendered}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.letsencrypt_certificate.rendered}\nEOF"
#   }
# }
