terraform {
  backend "azurerm" {
    key = "red/ambassador.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "azurerm" {
  alias = "global"

  version = "1.31.0"

  subscription_id = var.global_subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "kubernetes" {
  config_path = local.config_path
}

locals {
  config_path = "../../../components/kubernetes/.local/kubeconfig"
  namespace   = var.environment

  common_tags = merge(
    var.realm_common_tags,
    var.environment_common_tags,
    {
      "Component" = "Ambassador"
    },
  )
}

data "terraform_remote_state" "ingress_controller" {
  backend = "azurerm"
  config = {
    access_key           = "${var.realm_backend_access_key}"
    storage_account_name = "${var.realm_backend_storage_account_name}"
	  container_name       = "${var.realm_backend_container_name}"
    key                  = "red/ingress-controller.tfstate"
  }
}

resource "kubernetes_ingress" "api" {
  metadata {
    name      = "api"
    namespace = local.namespace

    annotations = {
      "cert-manager.io/cluster-issuer"     = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect" = "true"
      "kubernetes.io/ingress.class"        = "nginx"
      "kubernetes.io/tls-acme"             = "true"
    }
  }

  spec {
    rule {
      host = "api.${var.environment}.${var.dns_realm}-red.${var.region}.${var.cloud}.sapienceanalytics.com"
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
      host = "api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com"
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
        "api.${var.environment}.${var.dns_realm}-red.${var.region}.${var.cloud}.sapienceanalytics.com",
        "api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com",
        "api.${var.environment}.sapienceanalytics.com"
      ]
      secret_name = "ambassador-certs"
    }
  }
}

data "template_file" "ambassador-rbac" {
  template = file("templates/ambassador-rbac.yaml.tpl")

  vars = {
    replicas = var.ambassador_rbac_replicas
  }
}

resource "null_resource" "ambassador_rbac" {
  triggers = {
    template_changed = data.template_file.ambassador-rbac.rendered
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.ambassador-rbac.rendered}\nEOF"
  }

  provisioner "local-exec" {
    when = destroy

    command = "kubectl delete --kubeconfig=${local.config_path} -n ${local.namespace} -f - <<EOF\n${data.template_file.ambassador-rbac.rendered}\nEOF"
  }
}

resource "kubernetes_service" "ambassador" {
  metadata {
    name      = "ambassador"
    namespace = local.namespace
  }

  spec {
    selector = {
      service = "ambassador"
    }

    port {
      name = "http"
      port = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = "api"
    namespace = local.namespace
    annotations = {
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
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_app_alerts_mapping
prefix: /alerts/
service: sapience-app-alerts
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_app_dashboard_mapping
prefix: /dashboard/
service: sapience-app-dashboard
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_app_api_mapping
prefix: /
service: sapience-app-api
timeout_ms: 10000
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization
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
