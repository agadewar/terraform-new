resource "kubernetes_config_map" "canopy_notification_service" {
  metadata {
    name      = "canopy-notification-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/canopy-notification-service.properties")
  }
}

resource "kubernetes_secret" "canopy_notification_service" {
  metadata {
    name      = "canopy-notification-service"
    namespace = local.namespace
  }

  data = {
    "canopy.database.username" = var.mysql_canopy_username
    "canopy.database.password" = var.mysql_canopy_password
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "canopy_notification_service_deployment" {
  metadata {
    name = "canopy-notification-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-notification-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = 1

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-notification-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-notification-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-notification-service:1.3.0.docker-SNAPSHOT"
          name  = "canopy-notification-service"

          # image_pull_policy = "Always"

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-notification-service"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-notification-service"
                key  = "canopy.database.password"
              }
            }
          }

          env {
            name  = "notification.sms.amazonsns.topicarn"
            value = "dummy"
          }
          env {
            name  = "aws.accessKey"
            value = "dummy"
          }
          env {
            name  = "aws.secretKey"
            value = "dummy"
          }

          env {
            name  = "jms.queues"
            value = "canopy-notification-email,canopy-notification-push-notification,canopy-notification-sms,canopy-notification-twilio"
          }
          env {
            name  = "jms.type"
            value = "servicebus"
          }

          // servicebus settings
          env { 
            name  = "servicebus.host"
            value = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_hostname
          }
          env { 
            name  = "servicebus.key"   // 
            value = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
          }
          env { 
            name  = "servicebus.policy"
            value = "RootManageSharedAccessKey"
          }

          // queues
          env {
            name  = "canopy.notification.email.queue"
            value = "canopy-notification-email"
          }
          env {
            name  = "canopy.notification.push-notification.queue"
            value = "canopy-notification-push-notification"
          }
          env {
            name  = "canopy.notification.sms.queue"
            value = "canopy-notification-sms"
          }
          env {
            name  = "canopy.notification.twilio.queue"
            value = "canopy-notification-twilio"
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
              memory = "256M"
              cpu    = "150m"
            }
          }

          volume_mount { 
            name = "application-config"
            mount_path = "/opt/canopy/config"
            read_only = true
          }
          
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

        volume {
          name = "application-config"
          config_map {
            name = "canopy-notification-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "canopy-notification-service"
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

resource "kubernetes_service" "canopy_notification_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-notification-service"
    })
    
    annotations = {}
    
    name = "canopy-notification-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-notification-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}