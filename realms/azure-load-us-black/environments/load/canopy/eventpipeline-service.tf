data "template_file" "eventpipeline_conf" {
  template = file("templates/eventpipeline.conf.tpl")

  vars = {
    datalake_name           = "sapdl${replace(lower(var.realm), "-", "")}${var.environment}"
    # datalake_name           = "datalake"
    kafka_bootstrap_servers = var.kafka_bootstrap_servers
  }
}

resource "kubernetes_config_map" "eventpipeline_service" {
  metadata {
    name      = "eventpipeline-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/eventpipeline-service.properties")
    "eventpipeline.conf"     = data.template_file.eventpipeline_conf.rendered
  }
}

resource "kubernetes_secret" "eventpipeline_service" {
  metadata {
    name      = "eventpipeline-service"
    namespace = local.namespace
  }

  data = {
    "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
    "canopy.database.username" = var.mysql_canopy_username
    "canopy.database.password" = var.mysql_canopy_password
    "kafka.username"           = var.kafka_username
    "kafka.password"           = var.kafka_password
    "azure.datalake.key"       = data.terraform_remote_state.data_lake.outputs.azure_data_lake_storage_gen2_key_1
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

resource "kubernetes_deployment" "eventpipeline_service_deployment" {
  metadata {
    name = "eventpipeline-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "eventpipeline-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.eventpipeline_service_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "eventpipeline-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "eventpipeline-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          image_pull_policy = "Always"

          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/eventpipeline-service:1.5.1"
          name  = "eventpipeline-service"

          env { 
            name = "EVENTPIPELINE_SERVICE_XMX"
            value = "2048m"
          }

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "eventpipeline-service"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "eventpipeline-service"
                key  = "canopy.database.password"
              }
            }
          }
          env {
            name = "CANOPY_AMQP_PASSWORD"
            value_from {
              secret_key_ref {
                name = "eventpipeline-service"
                key  = "canopy.amqp.password"
              }
            }
          }
          env {
            name = "KAFKA_USERNAME"
            value_from {
              secret_key_ref {
                name = "eventpipeline-service"
                key  = "kafka.username"
              }
            }
          }
          env {
            name = "KAFKA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "eventpipeline-service"
                key  = "kafka.password"
              }
            }
          }
          env {
            name = "AZURE_DATALAKE_KEY"
            value_from {
              secret_key_ref {
                name = "eventpipeline-service"
                key  = "azure.datalake.key"
              }
            }
          }

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "centralized-logging"
          }

          env {
            name  = "JMS_TYPE"
            value = "servicebus"
          }

          // servicebus settings
          env { 
            name  = "SERVICEBUS_HOST"
            value = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_hostname
          }
          env { 
            name  = "SERVICEBUS_KEY" 
            value = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
          }
          env { 
            name  = "SERVICEBUS_POLICY"
            value = "RootManageSharedAccessKey"
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
              memory = var.eventpipeline_service_deployment_request_memory
              cpu    = var.eventpipeline_service_deployment_request_cpu
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

        # # Create an alias record because we have to hardcode the property name in eventpipeline-service's core-site.xml.  String
        # # interpolation is only allowed in the value.  So, we need somethign constant... which is the "datalake.dfs.core.windows.net"
        # # entry below.
        # host_aliases {
        #   ip = "sapiencedatalake${var.environment}.dfs.core.windows.net"
        #   hostnames = [ "datalake.dfs.core.windows.net" ]
        # }

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
            name = "eventpipeline-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "eventpipeline-service"
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

resource "kubernetes_service" "eventpipeline_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "eventpipeline-service"
    })
    
    annotations = {}
    
    name = "eventpipeline-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "eventpipeline-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}