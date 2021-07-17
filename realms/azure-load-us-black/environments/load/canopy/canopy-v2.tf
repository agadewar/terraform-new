resource "kubernetes_config_map" "canopy_v2" {
  metadata {
    name      = "canopy-v2"
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

resource "kubernetes_deployment" "canopy_v2_deployment" {
  metadata {
    name = "canopy-v2"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-v2"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.canopy_v2_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-v2"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-v2"
        })
        
        annotations = {}
      }

      spec {
        container {
          image_pull_policy = "Always"

          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-v2:3.49.5"
          name  = "canopy-v2"

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
              memory = var.canopy_v2_deployment_request_memory
              cpu    = var.canopy_v2_deployment_request_cpu
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

resource "kubernetes_service" "canopy_v2_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-v2"
    })
    
    annotations = {}
    
    name = "canopy-v2"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-v2"
    }

    port {
      # name        = "application"
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress" "canopy_v2" {
  metadata {
    name      = "canopy-v2"
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
      host = "canopy.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "canopy-v2"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    rule {
      host = "canopy.${var.environment}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "canopy-v2"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [
        "canopy.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com",
        "canopy.${var.environment}.sapienceanalytics.com"
      ]
      secret_name = "canopy-v2-certs"
    }
  }
}