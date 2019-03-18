terraform {
  backend "azurerm" {
    key = "sapience.environment.sandbox.canopy.terraform.tfstate"
  }
}

locals {
  namespace                         = "${var.environment}"
  config_path                       = "../../../realms/${var.realm}/kubernetes/kubeconfig"
  deployment_image_pull_secret_name = "canopy-container-registry-credential"

  common_labels = {
    "app.kubernetes.io/customer"    = "${var.realm_common_tags["Customer"]}"
	  "app.kubernetes.io/product"     = "${var.realm_common_tags["Product"]}"
    "app.kubernetes.io/realm"       = "${var.realm_common_tags["Realm"]}"
	  "app.kubernetes.io/environment" = "${var.environment_common_tags["Environment"]}"
	  "app.kubernetes.io/component"   = "Canopy"
	  "app.kubernetes.io/managed-by"  = "${var.realm_common_tags["ManagedBy"]}"
  }
}

module "eventpipeline_leaf_broker" {
  source = "../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "eventpipeline-leaf-broker"
  namespace = "${local.namespace}"

  deployment_image                  = "${var.canopy_container_registry_hostname}/eventpipeline-leaf-broker:1.2.3.docker-SNAPSHOT"
  deployment_replicas               = 1
  deployment_image_pull_policy      = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "768M"
          cpu    = "150m"
        }
      ]
    }
  ]

  default_token = "${var.kubernetes_namespace_default_token}"

  deployment_env = [
    {
      name = "CANOPY_DATABASE_USERNAME"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-leaf-broker"
              key  = "canopy.database.username"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_DATABASE_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-leaf-broker"
              key  = "canopy.database.password"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_AMQP_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-leaf-broker"
              key  = "canopy.amqp.password"
            }
          ]
        }
      ]
    }
  ]

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "eventpipeline-leaf-broker"
      }

      port = [
        {
          name        = "application"
          port        = 80
          target_port = 8080
        }
      ]

      # load_balancer_source_ranges = [
      #   "50.20.0.62/32",     # Banyan office
      #   "24.99.117.169/32",  # Ardis home
      #   "47.187.167.223/32"  # Sapience office
      # ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "canopy_user_service" {
  source = "../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "canopy-user-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/canopy-user-service:1.3.4.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "512M"
          cpu = "150m"
        }
      ]
    }
  ]

  default_token = "${var.kubernetes_namespace_default_token}"

  deployment_env = [
    {
      name = "CANOPY_DATABASE_USERNAME"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "canopy-user-service"
              key = "canopy.database.username"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_DATABASE_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "canopy-user-service"
              key = "canopy.database.password"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_AMQP_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-leaf-broker"
              key = "canopy.amqp.password"
            }
          ]
        }
      ]
    }
  ]

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "canopy-user-service"
      }

      port = [
        {
          name        = "application"
          port        = 80
          target_port = 8080
        },
        {
          name = "hazelcast"
          port = 5701
        }
      ]

      # load_balancer_source_ranges = [
      #   "50.20.0.62/32",     # Banyan office
      #   "24.99.117.169/32",  # Ardis home
      #   "47.187.167.223/32"  # Sapience office
      # ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "canopy_hierarchy_service" {
  source = "../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "canopy-hierarchy-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/canopy-hierarchy-service:1.4.8.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "256M"
          cpu = "150m"
        }
      ]
    }
  ]

  default_token = "${var.kubernetes_namespace_default_token}"

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "canopy-hierarchy-service"
      }

      port = [
        {
          name        = "application"
          port        = 80
          target_port = 8080
        }
      ]

      # load_balancer_source_ranges = [
      #   "50.20.0.62/32",     # Banyan office
      #   "24.99.117.169/32",  # Ardis home
      #   "47.187.167.223/32"  # Sapience office
      # ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "canopy_device_service" {
  source = "../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "canopy-device-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/canopy-device-service:1.7.4.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "768M"
          cpu = "150m"
        }
      ]
    }
  ]

  default_token = "${var.kubernetes_namespace_default_token}"

  deployment_env = [
    {
      name = "CANOPY_DATABASE_USERNAME"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "canopy-device-service"
              key = "canopy.database.username"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_DATABASE_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "canopy-device-service"
              key = "canopy.database.password"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_AMQP_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "canopy-device-service"
              key = "canopy.amqp.password"
            }
          ]
        }
      ]
    },
    {
      name = "GOOGLE_API_KEY"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "canopy-device-service"
              key = "google.api.key"
            }
          ]
        }
      ]
    }
  ]

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "canopy-device-service"
      }

      port = [
        {
          name        = "application"
          port        = 80
          target_port = 8080
        }
      ]

      # load_balancer_source_ranges = [
      #   "50.20.0.62/32",     # Banyan office
      #   "24.99.117.169/32",  # Ardis home
      #   "47.187.167.223/32", # Sapience office
      #   "208.82.111.61/32"   # Drury hotel
      # ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "eventpipeline_service" {
  source = "../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "eventpipeline-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/eventpipeline-service:1.2.1.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "768M"
          cpu = "150m"
        }
      ]
    }
  ]

  default_token = "${var.kubernetes_namespace_default_token}"

  readiness_probe_timeout_seconds = 10
  liveness_probe_timeout_seconds  = 10

  deployment_env = [
    {
      name = "CANOPY_DATABASE_USERNAME"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-service"
              key = "canopy.database.username"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_DATABASE_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-service"
              key = "canopy.database.password"
            }
          ]
        }
      ]
    },
    {
      name = "CANOPY_AMQP_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-service"
              key = "canopy.amqp.password"
            }
          ]
        }
      ]
    }
  ]

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "eventpipeline-service"
      }

      port = [
        {
          name        = "application"
          port        = 80
          target_port = 8080
        }
      ]

      # load_balancer_source_ranges = [
      #   "50.20.0.62/32",     # Banyan office
      #   "24.99.117.169/32",  # Ardis home
      #   "47.187.167.223/32"  # Sapience office
      # ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "sapience_event_hub_journal" {
  source = "../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "sapience-event-hub-journal"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/sapience-event-hub-journal:1.0.0-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "512M"
          cpu = "150m"
        }
      ]
    }
  ]

  default_token = "${var.kubernetes_namespace_default_token}"

  deployment_env = [
    {
      name = "CANOPY_AMQP_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "sapience-event-hub-journal"
              key = "canopy.amqp.password"
            }
          ]
        }
      ]
    },
   {
      name = "CANOPY_EVENT_HUB_PASSWORD"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "sapience-event-hub-journal"
              key = "canopy.event-hub.password"
            }
          ]
        }
      ]
    } 
  ]

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "sapience-event-hub-journal"
      }

      port = [
        {
          name        = "application"
          port        = 80
          target_port = 8080
        }
      ]

      # load_balancer_source_ranges = [
      #   "50.20.0.62/32",     # Banyan office
      #   "24.99.117.169/32",  # Ardis home
      #   "47.187.167.223/32"  # Sapience office
      # ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}
