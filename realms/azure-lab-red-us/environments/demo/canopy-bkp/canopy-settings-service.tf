resource "kubernetes_config_map" "canopy_settings_service" {
  metadata {
    name      = "canopy-settings-service"
    namespace = local.namespace
  }

  data = {
    "global.properties"      = data.template_file.global_properties.rendered
    "application.properties" = file("files/canopy-settings-service.properties")
  }
}

resource "kubernetes_secret" "canopy_settings_service" {
  metadata {
    name      = "canopy-settings-service"
    namespace = local.namespace
  }

  data = {}

  type = "Opaque"
}

resource "kubernetes_deployment" "canopy_settings_service_deployment" {
  metadata {
    name = "canopy-settings-service"
    namespace = local.namespace

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-settings-service"
    })
    
    annotations = {}
  }

  spec {
    replicas = 1

    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector {
      match_labels = {
        "sapienceanalytics.com/name" = "canopy-settings-service"
      }
    }

    template {
      metadata {
        // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
        //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
        labels = merge(local.common_labels, {
          "sapienceanalytics.com/name" = "canopy-settings-service"
        })
        
        annotations = {}
      }

      spec {
        container {
          # See: https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html
          image = "${var.canopy_container_registry_hostname}/canopy-settings-service:1.1.6.docker-SNAPSHOT"
          name  = "canopy-settings-service"

          env {
            name  = "canopy.security.service.auhtenticationTokenName"
            value = "canopy-security-token"
          }
          env {
            name  = "canopy.security.service.url"
            value = "http://canopy-user-service/security/"
          }
          env {
            name  = "ignoreBootstrap"
            value = "false"
          }
          env {
            name  = "management.add-application-context-header"
            value = "false"
          }
          env {
            name  = "rootName"
            value = "Sapience"
          }
          env {
            name  = "spring.application.name"
            value = "canopy-settings"
          }
          env {
            name  = "spring.data.mongodb.uri"
            value = "mongodb://canopy-settings-mongodb-${var.realm}-${var.environment}:${data.terraform_remote_state.database.outputs.canopy_settings_mongodb_cosmos_password}@canopy-settings-mongodb-${var.realm}-${var.environment}.documents.azure.com:10255/settings?ssl=true&maxIdleTimeMS=900000"
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
            name = "canopy-settings-service"
          }
        }

        volume {
          name = "application-secrets"
          secret {
            secret_name = "canopy-settings-service"
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

resource "kubernetes_service" "canopy_settings_service_service" {
  metadata {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    labels = merge(local.common_labels, {
      "sapienceanalytics.com/name" = "canopy-settings-service"
    })
    
    annotations = {}
    
    name = "canopy-settings-service"
    namespace = local.namespace
  }

  spec {
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    selector = {
      "sapienceanalytics.com/name" = "canopy-settings-service"
    }

    port {
      name        = "application"
      port        = 80
      target_port = 8080
    }
  }
}