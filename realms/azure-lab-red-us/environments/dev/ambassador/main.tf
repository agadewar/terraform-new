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
      "nginx.ingress.kubernetes.io/proxy-connect-timeout" = "120"
      "nginx.ingress.kubernetes.io/proxy-read-timeout" = "120"
      "nginx.ingress.kubernetes.io/proxy-send-timeout" = "120"
    }
  }

  spec {
    rule {
      host = "api.${var.environment}.${var.dns_realm}-black.${var.region}.${var.cloud}.sapienceanalytics.com"
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
        "api.${var.environment}.${var.dns_realm}-black.${var.region}.${var.cloud}.sapienceanalytics.com",
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
    replicas      = var.ambassador_rbac_replicas
    namespace     = var.environment
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
name:  canopy_auth0_service_mapping
prefix: /auth0/
service: canopy-auth0-service
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
name:  canopy_location_service_mapping
prefix: /location/
service: canopy-location-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_marketplace_service_mapping
prefix: /marketplace/
service: canopy-marketplace-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_notification_service_mapping
prefix: /notification/
service: canopy-notification-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_setting_service_mapping
prefix: /setting/
service: canopy-setting-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_settings_service_mapping
prefix: /settings/
service: canopy-settings-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_user_service_mapping
prefix: /user/
service: canopy-user-service
timeout_ms: 60000
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_leaf_broker_mapping
prefix: /leafbroker/
service: eventpipeline-leaf-broker
timeout_ms: 120000
connect_timeout_ms: 120000
circuit_breakers:
- max_connections: 8000
  max_pending_requests: 8000
  max_requests: 8000
---
#apiVersion: ambassador/v1
#kind:  Mapping
#name:  eventpipeline_leaf_broker_eh_mapping
#prefix: /leafbroker_eh/
#service: eventpipeline-leaf-broker-eh
#timeout_ms: 120000
#connect_timeout_ms: 120000
#circuit_breakers:
#- max_connections: 8000
#  max_pending_requests: 8000
#  max_requests: 8000
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_service_mapping
prefix: /eventpipeline/
service: eventpipeline-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  kpi_service_mapping
prefix: /kpi/
service: kpi-service
timeout_ms: 30000
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_users_api_mapping
prefix: /admin/users/
service: admin-users-api
rewrite: /admin/users/
timeout_ms: 60000
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_settings_api_mapping
prefix: /admin/settings/
service: admin-settings-api
rewrite: /admin/settings/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_app_activity_api_mapping
prefix: /admin/specs/
service: admin-app-activity-api
rewrite: /admin/specs/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_org_api_mapping
prefix: /admin/org/
service: admin-org-api
rewrite: /admin/org/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_app_api_mapping
prefix: /
service: sapience-app-api
timeout_ms: 20000
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_app_alerts_mapping
prefix: /alerts/
service: sapience-app-alerts
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_meeting_mapping
prefix: /external/integration/
service: sapience-meeting
rewrite: /external/integration/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_uploads_api_mapping
prefix: /admin/uploads/
service: admin-uploads-api
rewrite: /admin/uploads/
timeout_ms: 20000
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_openapi_mapping
prefix: /openapi
service: sapience-open-api
rewrite: /openapi
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_app_dashboard_mapping
prefix: /dashboard/
service: sapience-app-dashboard
timeout_ms: 100000
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_cache_control_mapping
prefix: /sapience/cache/
service: sapience-cache-control
rewrite: /sapience/cache/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_openapi_developerportal_delegation_mapping
prefix: /openapi/delegation/
service: sapience-openapi-developerportal-delegation
rewrite: /openapi/delegation/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_reports_api_mapping
prefix: /admin/reports/
service: admin-reports-api
rewrite: /admin/reports/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  sapience_third_party_integration_api
prefix: /external/integration/
service: sapience-third-party-integration-api
rewrite: /external/integration/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
---
apiVersion: ambassador/v1
kind:  Mapping
name:  admin_dashboard_api_mapping
prefix: /admin/dashboard/
service: admin-dashboard-api
rewrite: /admin/dashboard/
cors:
  origins: "*"
  methods: GET, POST, PUT, DELETE, OPTIONS
  headers: Content-Type, Authorization, v-request-id
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
