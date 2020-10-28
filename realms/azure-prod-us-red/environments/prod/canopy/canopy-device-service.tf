resource "kubernetes_config_map" "canopy_device_service" {
  metadata {
    name      = "canopy-device-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/canopy-device-service.properties")
  }
}

resource "kubernetes_secret" "canopy_device_service" {
  metadata {
    name      = "canopy-device-service"
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
    "google.api.key"           = var.google_api_key
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "canopy_device_service_deployment" {
  metadata {
    name = "canopy-device-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-device-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.canopy_device_service_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-device-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-device-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-device-service:1.19.5.docker-SNAPSHOT"
          name  = "canopy-device-service"

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-device-service"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-device-service"
                key  = "canopy.database.password"
              }
            }
          }
          env {
            name = "CANOPY_AMQP_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-device-service"
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
                name = "canopy-device-service"
                key  = "kafka.username"
              }
            }
          }
          env {
            name = "KAFKA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-device-service"
                key  = "kafka.password"
              }
            }
          }
          env {
            name = "GOOGLE_API_KEY"
            value_from {
              secret_key_ref {
                name = "canopy-device-service"
                key  = "google.api.key"
              }
            }
          }

          env {
            name  = "com.banyanhills.canopy.device.eventhandler.AllDeviceEventHandler.disabled"
            value = "true"
          }

          env {
            name  = "server.undertow.worker-threads"
            value = "2000"
          }

          env {
            name  = "jms.queues"
            value = "canopy-device-agent-info,canopy-device-device-event,canopy-device-device-component,canopy-device-file-version,canopy-device-generic-data-info,canopy-device-heartbeat,canopy-device-leaf-versions,canopy-device-software-update,canopy-device-system-info,canopy-device-system-utilization"
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
            name  = "canopy.queue.agentInfo"
            value = "canopy-device-agent-info"
          }
          env {
            name  = "canopy.queue.deviceEvent"
            value = "canopy-device-device-event"
          }
          env {
            name  = "canopy.queue.deviceComponent"
            value = "canopy-device-device-component"
          }
          env {
            name  = "canopy.queue.fileVersion"
            value = "canopy-device-file-version"
          }
          env {
            name  = "canopy.queue.generic.dataInfo"
            value = "canopy-device-generic-data-info"
          }
          env {
            name  = "canopy.queue.heartbeat"
            value = "canopy-device-heartbeat"
          }
          env {
            name  = "canopy.queue.leafVersions"
            value = "canopy-device-leaf-versions"
          }
          env {
            name  = "canopy.queue.softwareUpdate"
            value = "canopy-device-software-update"
          }
          env {
            name  = "canopy.queue.systemInfo"
            value = "canopy-device-system-info"
          }
          env {
            name  = "canopy.queue.systemUtilization"
            value = "canopy-device-system-utilization"
          }

          // disable custom eventhandlers
          env {
            name  = "chargeit.enabled"
            value = "false"
          }
          env {
            name  = "ipa.enabled"
            value = "false"
          }
          env {
            name  = "mm.enabled"
            value = "false"
          }
          env {
            name  = "optconnect.enabled"
            value = "false"
          }
          env {
            name  = "posiflex.enabled"
            value = "false"
          }
          env {
            name  = "pti.enabled"
            value = "false"
          }
          env {
            name  = "wu.enabled"
            value = "false"
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
              memory = var.canopy_device_service_deployment_request_memory
              cpu    = var.canopy_device_service_deployment_request_cpu
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
            name = "canopy-device-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "canopy-device-service"
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

resource "kubernetes_service" "canopy_device_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-device-service"
    })
    
    annotations = {}
    
    name = "canopy-device-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-device-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}