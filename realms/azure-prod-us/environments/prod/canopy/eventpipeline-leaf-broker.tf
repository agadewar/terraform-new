resource "kubernetes_config_map" "eventpipeline_leaf_broker" {
  metadata {
    name      = "eventpipeline-leaf-broker"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/eventpipeline-leaf-broker.properties")
  }
}

resource "kubernetes_secret" "eventpipeline_leaf_broker" {
  metadata {
    name      = "eventpipeline-leaf-broker"
    namespace = local.namespace
  }

  data = {
    "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
    "canopy.database.username" = var.sql_server_canopy_username
    "canopy.database.password" = var.sql_server_canopy_password
    "kafka.username"           = var.kafka_username
    "kafka.password"           = var.kafka_password
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "eventpipeline_leafbroker_deployment" {
  metadata {
    name = "eventpipeline-leaf-broker"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "eventpipeline-leaf-broker"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.eventpipeline_leaf_broker_service_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "eventpipeline-leaf-broker"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "eventpipeline-leaf-broker"
        })
        
        annotations = {}
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/eventpipeline-leaf-broker:1.3.0.docker-SNAPSHOT"
          name  = "eventpipeline-leaf-broker"

          image_pull_policy = "Always"

          env { 
            name = "CANOPY_DATABASE_USERNAME"
            value_from {
              secret_key_ref {
                name = "eventpipeline-leaf-broker"
                key  = "canopy.database.username"
              }
            }
          }
          env {
            name = "CANOPY_DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "eventpipeline-leaf-broker"
                key  = "canopy.database.password"
              }
            }
          }
          env {
            name = "CANOPY_AMQP_PASSWORD"
            value_from {
              secret_key_ref {
                name = "eventpipeline-leaf-broker"
                key  = "canopy.amqp.password"
              }
            }
          }
          env {
            name = "KAFKA_USERNAME"
            value_from {
              secret_key_ref {
                name = "eventpipeline-leaf-broker"
                key  = "kafka.username"
              }
            }
          }
          env {
            name = "KAFKA_PASSWORD"
            value_from {
              secret_key_ref {
                name = "eventpipeline-leaf-broker"
                key  = "kafka.password"
              }
            }
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
              memory = var.eventpipeline_leaf_broker_service_deployment_request_memory
              cpu    = var.eventpipeline_leaf_broker_service_deployment_request_cpu
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
            name = "eventpipeline-leaf-broker"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "eventpipeline-leaf-broker"
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

resource "kubernetes_service" "eventpipeline_leafbroker_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "eventpipeline-leaf-broker"
    })
    
    annotations = {}
    
    name = "eventpipeline-leaf-broker"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "eventpipeline-leaf-broker"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}