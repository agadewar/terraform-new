resource "kubernetes_config_map" "canopy_schedule_service" {
  metadata {
    name      = "canopy-schedule-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/canopy-schedule-service.properties")
  }
}

resource "kubernetes_secret" "canopy_schedule_service" {
  metadata {
    name      = "canopy-schedule-service"
    namespace = local.namespace
  }

  data = {
    "canopy.database.username" = var.mysql_canopy_username
    "canopy.database.password" = var.mysql_canopy_password
    "canopy.service-account.username" = var.canopy_service_account_username
    "canopy.service-account.password" = var.canopy_service_account_password
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "canopy_schedule_service_deployment" {
  metadata {
    name = "canopy-schedule-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-schedule-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.canopy_schedule_service_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-schedule-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-schedule-service"
        })
        
        annotations = {}
      }

      spec {
        container {

          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-schedule-service:1.4.0-20220328160955774"
          name  = "canopy-schedule-service"

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-schedule-service"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-schedule-service"
                key  = "canopy.database.password"
              }
            }
          }

          env {
            name = "CANOPY_SERVICE_ACCOUNT_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "canopy.service-account.username"
              }
            }
          }
          env {
            name = "CANOPY_SERVICE_ACCOUNT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "canopy.service-account.password"
              }
            }
          }
          
          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "centralized-logging"
          }

          env {
            name  = "canopy.portal.url.versions"
            value = "[(null):'https://canopy.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com','3':'https://canopyv3.${var.environment}.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com']"
          }

          # env {
          #   name  = "messaging.enabled"
          #   value = "false"
          # }
          # env {
          #   name  = "messaging.password"
          #   value = "dummy"
          # }
          # env {
          #   name  = "messaging.server"
          #   value = "dummy"
          # }
          # env {
          #   name  = "messaging.username"
          #   value = "dummy"
          # }

          env {
            name  = "jms.type"
            value = "servicebus"
          }

          readiness_probe {
            http_get {
              path = "/ping"
              port = 8080
            }

            initial_delay_seconds = 15
            period_seconds = 5
            timeout_seconds = 2
            failure_threshold = 3
          }

          # liveness_probe {
          #   http_get {
          #     path = "/ping"
          #     port = 8080
          #   }

          #   initial_delay_seconds = 180
          #   period_seconds = 10
	        #   timeout_seconds = 2
          #   failure_threshold = 6
          # }

          resources {
            requests {
              memory = var.canopy_schedule_service_deployment_request_memory
              cpu    = var.canopy_schedule_service_deployment_request_cpu
            }
          }

          volume_mount { 
            name = "application-config"
            mount_path = "/opt/canopy/config"
            read_only = true
          }
          
          # needed by the user-service for Hazelcast
          # this is being done due to "automountServiceAccountToken" not being supported (https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38)
          volume_mount {
            name = "default-token"
            read_only = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }
        }

        # needed by the user-service for Hazelcast
        # this is being done due to "automountServiceAccountToken" not being supported (https://github.com/terraform-providers/terraform-provider-kubernetes/issues/38)
        volume {
		      name = "default-token"
		      secret {
            secret_name = data.local_file.default_token_secret_name.content
		        default_mode = "0420"
		      }
        }

        volume {
          name = "application-config"
          config_map {
            name = "canopy-schedule-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "canopy-schedule-service"
          }
        }
        
        # See: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
        image_pull_secrets {
          name = local.canopy_container_registry_image_pull_secret_name
        }
      }
    }
  }
}

resource "kubernetes_service" "canopy_schedule_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-schedule-service"
    })
    
    annotations = {}
    
    name = "canopy-schedule-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-schedule-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}