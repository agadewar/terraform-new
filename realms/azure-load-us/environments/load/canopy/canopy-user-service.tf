resource "kubernetes_config_map" "canopy_user_service" {
  metadata {
    name      = "canopy-user-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/canopy-user-service.properties")
    "service-permission.json" = file("files/service-permission.json")
  }
}

resource "kubernetes_secret" "canopy_user_service" {
  metadata {
    name      = "canopy-user-service"
    namespace = local.namespace
  }

  data = {
    "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
    "canopy.database.username" = var.mysql_canopy_username
    "canopy.database.password" = var.mysql_canopy_password
    "canopy.service-account.username" = var.canopy_service_account_username
    "canopy.service-account.password" = var.canopy_service_account_password
    "kafka.username"           = var.kafka_username
    "kafka.password"           = var.kafka_password
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "canopy_user_service_deployment" {
  metadata {
    name = "canopy-user-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-user-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.canopy_user_service_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-user-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-user-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-user-service:2.5.6.docker-SNAPSHOT"
          name  = "canopy-user-service"

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "canopy.database.password"
              }
            }
          }
          env {
            name = "CANOPY_AMQP_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "canopy.amqp.password"
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
            name = "KAFKA_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "kafka.username"
              }
            }
          }
          env {
            name = "KAFKA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-user-service"
                key  = "kafka.password"
              }
            }
          }
          env {
            name = "REDIS_PASSWORD"
            value_from {
              secret_key_ref {
                name = "redis"
                key  = "redis-password"
              }
            }
          }

          # env {
          #   name  = "update.token.usage.statistics"
          #   value = "false"
          # }

          # env {
          #   name  = "cache.token.ttl-seconds"
          #   value = "300"
          # }     

          env {
            name  = "canopy.security.userDetailsCacheEnabled"
            value = "true"
          }     

          env {
            name  = "canopy.security.service-permission-source"
            value = "/opt/canopy/config/service-permission.json"
          }

          # env {
          #   name  = "logging.level.com.banyanhills.canopy.user.auth.provider"
          #   value = "DEBUG"
          # }

          # env {
          #   name  = "logging.level.com.banyanhills.canopy.user.service.TokenService"
          #   value = "DEBUG"
          # }

          # env {
          #   name  = "logging.level.com.banyanhills.canopy.user.cache.Cache"
          #   value = "DEBUG"
          # }

          env {
            name  = "server.undertow.worker-threads"
            value = "2000"
          }

          env {
            name  = "spring.datasource.tomcat.initial-size"
            value = "50"
          }
          env {
            name  = "spring.datasource.tomcat.max-active"
            value = "300"
          }
          env {
            name  = "spring.datasource.tomcat.min-idle"
            value = "50"
          }
          env {
            name  = "spring.datasource.tomcat.max-idle"
            value = "60"
          }
          env {
            name  = "spring.datasource.tomcat.min-evictable-idle-time-millis"
            value = "5000"
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

          liveness_probe {
            http_get {
              path = "/ping"
              port = 8080
            }

            initial_delay_seconds = 180
            period_seconds = 10
	          timeout_seconds = 2
            failure_threshold = 6
          }

          resources {
            requests {
              memory = var.canopy_user_service_deployment_request_memory
              cpu    = var.canopy_user_service_deployment_request_cpu
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
            name = "canopy-user-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "canopy-user-service"
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

resource "kubernetes_service" "canopy_user_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-user-service"
    })
    
    annotations = {}
    
    name = "canopy-user-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-user-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
    
    port {
      name = "hazelcast"
      port = 5701
    }
  }
}