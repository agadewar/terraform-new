resource "kubernetes_config_map" "kpi_service" {
  metadata {
    name      = "kpi-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/kpi-service.properties")
  }
}

resource "kubernetes_secret" "kpi_service" {
  metadata {
    name      = "kpi-service"
    namespace = local.namespace
  }

  data = {
    # "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
    "canopy.database.username" = var.mysql_canopy_username
    "canopy.database.password" = var.mysql_canopy_password
    # "kafka.username"           = var.kafka_username
    # "kafka.password"           = var.kafka_password
    # "azure.datalake.key"       = data.terraform_remote_state.data_lake.outputs.azure_data_lake_storage_gen2_key_1
  }

  type = "Opaque"
}

# resource "kubernetes_service" "datalake" {
#   metadata {
#     name = "datalake"
#     namespace = local.namespace
#   }

#   spec {
#     external_name = "sapdl${replace(lower(var.realm), "-", "")}${var.environment}.dfs.core.windows.net"
#     # external_name = "datalake.dfs.core.windows.net"

#     type = "ExternalName"
#   }
# }

resource "kubernetes_deployment" "kpi_service_deployment" {
  metadata {
    name = "kpi-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "kpi-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = 1

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "kpi-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "kpi-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/kpi-service:2.14.0.docker"
          name  = "kpi-service"

          image_pull_policy = "Always"

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "kpi-service"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "kpi-service"
                key  = "canopy.database.password"
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
          #   name = "CANOPY_AMQP_PASSWORD"
          #   value_from {
          #     secret_key_ref {
          #       name = "eventpipeline-service"
          #       key  = "canopy.amqp.password"
          #     }
          #   }
          # }
          # env {
          #   name = "KAFKA_USERNAME"
          #   value_from {
          #     secret_key_ref {
          #       name = "eventpipeline-service"
          #       key  = "kafka.username"
          #     }
          #   }
          # }
          # env {
          #   name = "KAFKA_PASSWORD"
          #   value_from {
          #     secret_key_ref {
          #       name = "eventpipeline-service"
          #       key  = "kafka.password"
          #     }
          #   }
          # }
          # env {
          #   name = "AZURE_DATALAKE_KEY"
          #   value_from {
          #     secret_key_ref {
          #       name = "eventpipeline-service"
          #       key  = "azure.datalake.key"
          #     }
          #   }
          # }

          env {
            name  = "bootstrap.enabled"
            value = "true"
          }

          env {
            name  = "influx.url"
            value = "http://influxdb:8086"
          }
          env {
            name  = "influx.username"
            value = "admin"
          }
          env {
            name  = "influx.password"
            value = var.influxdb_password
          }
          env {
            name  = "influx.retentionPolicy"
            value = "autogen"
          }

          env {
            name  = "canopy.security.service.username"
            value = "dummy"
          }
          env {
            name  = "canopy.security.service.password"
            value = "dummy"
          }

          env {
            name  = "jms.queues"
            value = "canopy-kpi,canopy-publish"
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
            name  = "canopy.queue.kpi"
            value = "canopy-kpi"
          }
          env {
            name  = "canopy.queue.publish"
            value = "canopy-publish"
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
              memory = "2048M"
              cpu    = "1000m"
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

        # # Create an alias record because we have to hardcode the property name in eventpipeline-service's core-site.xml.  String
        # # interpolation is only allowed in the value.  So, we need somethign constant... which is the "datalake.dfs.core.windows.net"
        # # entry below.
        # host_aliases {
        #   ip = "sapiencedatalake${var.environment}.dfs.core.windows.net"
        #   hostnames = [ "datalake.dfs.core.windows.net" ]
        # }

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
            name = "kpi-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "kpi-service"
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

resource "kubernetes_service" "kpi_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "kpi-service"
    })
    
    annotations = {}
    
    name = "kpi-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "kpi-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}