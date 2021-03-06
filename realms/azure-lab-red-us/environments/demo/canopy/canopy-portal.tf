resource "kubernetes_config_map" "canopy_portal" {
  metadata {
    name      = "canopy-portal"
    namespace = local.namespace
  }

  data = {
    # "global.properties"      = data.template_file.global_properties.rendered
    # "application.properties" = file("files/canopy-device-service.properties")
  }
}

# resource "kubernetes_secret" "canopy_device_service" {
#   metadata {
#     name      = "canopy-device-service"
#     namespace = local.namespace
#   }

#   data = {
#     "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
#     "canopy.database.username" = var.mysql_canopy_username
#     "canopy.database.password" = var.mysql_canopy_password
#     "kafka.username"           = var.kafka_username
#     "kafka.password"           = var.kafka_password
#     "google.api.key"           = var.google_api_key
#   }

#   type = "Opaque"
# }

resource "kubernetes_deployment" "canopy_portal_deployment" {
  metadata {
    name = "canopy-portal"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-portal"
    })
    
    annotations = {}
  }

  spec {
    replicas = 1

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-portal"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-portal"
        })
        
        annotations = {}
      }

      spec {
        container {

          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-portal:3.16.0-beta.20210721200507807"
          name  = "canopy-portal"

          // fall back to prior URL lookup through environment variables, not through call to setting-service;
          // any non-empty string value here will cause portal to not use the endpoints from the setting-service
          env {
            name = "ENVIRONMENT_IGNORE_SERVICE_ENDPOINTS"
            value = "true"
          }
          env {
            name = "ENVIRONMENT_DISABLE_DOWN_FOR_MAINTENANCE"
            value = "true"
          }

          env {
            name = "ENVIRONMENT_AUTH0_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/auth0"
          }
          env { 
            name = "ENVIRONMENT_DEVICE_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/device"
          }
          env { 
            name = "ENVIRONMENT_HIERARCHY_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/hierarchy"
          }
          env { 
            name = "ENVIRONMENT_KPI_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/kpi"
          }
          env { 
            name = "ENVIRONMENT_LOCATION_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/location"
          }
          env {
            name = "ENVIRONMENT_MARKETPLACE_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/marketplace"
          }
          env {
            name = "ENVIRONMENT_NOTIFICATION_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/notification"
          }
          env { 
            name = "ENVIRONMENT_NOTIFICATION_WS_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/notification"
          }
          env { 
            name = "ENVIRONMENT_SETTING_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/setting"
          }
          env { 
            name = "ENVIRONMENT_SETTINGS_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/settings"
          }
          env { 
            name = "ENVIRONMENT_USER_SERVICE_BASE_URL"
            value = "https://api.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com/user"
          }
          env { 
            name  = "ENVIRONMENT_APPEND_PATH_PREFIX_ON_MODALS"
            value = "true"
          }

          # env {
          #   name = "CANOPY_DATABASE_PASSWORD"
          #   value_from {
          #     secret_key_ref {
          #       name = "canopy-device-service"
          #       key  = "canopy.database.password"
          #     }
          #   }
          # }
          # env {
          #   name = "CANOPY_AMQP_PASSWORD"
          #   value_from {
          #     secret_key_ref {
          #       name = "canopy-device-service"
          #       key  = "canopy.amqp.password"
          #     }
          #   }
          # }
          # env {
          #   name = "KAFKA_USERNAME"
          #   value_from {
          #     secret_key_ref {
          #       name = "canopy-device-service"
          #       key  = "kafka.username"
          #     }
          #   }
          # }
          # env {
          #   name = "KAFKA_PASSWORD"
          #   value_from {
          #     secret_key_ref {
          #       name = "canopy-device-service"
          #       key  = "kafka.password"
          #     }
          #   }
          # }
          # env {
          #   name = "GOOGLE_API_KEY"
          #   value_from {
          #     secret_key_ref {
          #       name = "canopy-device-service"
          #       key  = "google.api.key"
          #     }
          #   }
          # }

          readiness_probe {
            http_get {
              path = "/index.html"
              port = 80
            }

            # initial_delay_seconds = 15
            # period_seconds = 5
            # timeout_seconds = 2
            # failure_threshold = 3
          }

          liveness_probe {
            http_get {
              path = "/index.html"
              port = 80
            }

            # initial_delay_seconds = 180
            # period_seconds = 10
	          # timeout_seconds = 2
            # failure_threshold = 6
          }

          resources {
            requests {
              memory = "64M"
              cpu    = "150m"
            }
          }

          # volume_mount { 
          #   name = "application-config"
          #   mount_path = "/opt/canopy/config"
          #   read_only = true
          # }
          
          # # needed by the user-service for Hazelcast
          # # this is being done due to "automountServiceAccountToken" not being supported (https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38)
          # volume_mount {
          #   name = "default-token"
          #   read_only = true
          #   mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          # }
        }

        # # needed by the user-service for Hazelcast
        # # this is being done due to "automountServiceAccountToken" not being supported (https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38)
        # volume {
		    #   name = "default-token"
		    #   secret {
        #     secret_name = data.local_file.default_token_secret_name.content
		    #     default_mode = "0420"
		    #   }
        # }

        # volume {
        #   name = "application-config"
        #   config_map {
        #     name = "canopy-device-service"
        #   }
        # }

        # volume {
        #   name = "application-secrets"
        #   secret {
        #     secret_name = "canopy-device-service"
        #   }
        # }
        
        # See: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
        image_pull_secrets {
          name = local.canopy_container_registry_image_pull_secret_name
        }
      }
    }
  }
}

resource "kubernetes_service" "canopy_portal_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-portal"
    })
    
    annotations = {}
    
    name = "canopy-portal"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-portal"
    }

    port {
      # name        = "application"
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "canopy_portal" {
  metadata {
    name      = "canopy-portal"
    namespace = local.namespace

    annotations = {
      # "certmanager.k8s.io/acme-challenge-type" = "dns01"
      # "certmanager.k8s.io/acme-dns01-provider" = "azure-dns"
      # "certmanager.k8s.io/cluster-issuer"      = "letsencrypt-staging"
      # ###  TODO - set "true" on "ssl-redirect" after upgrade of cert-manager
      # "ingress.kubernetes.io/ssl-redirect"     = "false"
      # "kubernetes.io/ingress.class"            = "nginx"
      # "kubernetes.io/tls-acme"                 = "true"
      "cert-manager.io/cluster-issuer"     = "letsencrypt-prod"
      "ingress.kubernetes.io/ssl-redirect" = "true"
      "kubernetes.io/ingress.class"        = "nginx"
      "kubernetes.io/tls-acme"             = "true"
    }
  }

  spec {
    rule {
      host = "canopyv3.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "canopy-portal"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    rule {
      host = "canopyv3.${var.environment}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "canopy-portal"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [
        "canopyv3.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com",
        "canopyv3.${var.environment}.sapienceanalytics.com"
      ]
      secret_name = "canopy-portal-certs"
    }
  }
}