resource "kubernetes_config_map" "canopy_hierarchy_service" {
  metadata {
    name      = "canopy-hierarchy-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/canopy-hierarchy-service.properties")
    "gremlin.yaml"           = data.template_file.gremlin_cosmos.rendered
  }
}

data "template_file" "gremlin_cosmos" {
  template = file("templates/gremlin-cosmos.yaml.tpl")

  vars = {
    realm                            = var.realm
    environment                      = var.environment
    canopy_hierarchy_cosmos_password = data.terraform_remote_state.database.outputs.canopy_hierarchy_cosmos_password
  }
}

resource "kubernetes_secret" "canopy_hierarchy_service" {
  metadata {
    name      = "canopy-hierarchy-service"
    namespace = local.namespace
  }

  data = {
    "canopy.service-account.username" = var.canopy_service_account_username
    "canopy.service-account.password" = var.canopy_service_account_password
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "canopy_hierarchy_service_deployment" {
  metadata {
    name = "canopy-hierarchy-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-hierarchy-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = var.canopy_hierarchy_service_deployment_replicas

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-hierarchy-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-hierarchy-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          # image = "${var.canopy_container_registry_hostname}/canopy-hierarchy-service:1.19.0"
          image = "${var.canopy_container_registry_hostname}/canopy-hierarchy-service:1.20.0-SNAPSHOT"
          name  = "canopy-hierarchy-service"

          env {
            name = "CANOPY_SERVICE_ACCOUNT_USERNAME"
            value_from {
              secret_key_ref {
                name = "canopy-hierarchy-service"
                key  = "canopy.service-account.username"
              }
            }
          }
          env {
            name = "CANOPY_SERVICE_ACCOUNT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "canopy-hierarchy-service"
                key  = "canopy.service-account.password"
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

          env {
            name  = "SPRING_PROFILES_ACTIVE"
            value = "centralized-logging"
          }

          # env {
          #   name  = "canopy.security.userDetailsCacheEnabled"
          #   value = "true"
          # }

          env {
            name  = "logging.level.com.banyanhills.canopy.hierarchy"
            value = "INFO"
          }

          env {
            name  = "server.undertow.worker-threads"
            value = "2000"
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
              memory = var.canopy_hierarchy_service_deployment_request_memory
              cpu    = var.canopy_hierarchy_service_deployment_request_cpu
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
            name = "canopy-hierarchy-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "canopy-hierarchy-service"
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

resource "kubernetes_service" "canopy_hierarchy_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-hierarchy-service"
    })
    
    annotations = {}
    
    name = "canopy-hierarchy-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-hierarchy-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}