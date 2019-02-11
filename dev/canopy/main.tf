terraform {
  backend "azurerm" {
    access_key           = "gx3N29hLwW2OC+kO5FaAedBpjlh83kY35dpOrJZvdYAB+1CG5iHm85/763rJCiEZ6CY+cwSq+ZAVOvK8f2o4Hg=="
    storage_account_name = "terraformstatesapience"
	  container_name       = "tfstate"
    key                  = "sapience.dev.canopy.terraform.tfstate"
  }
}

locals {
  namespace                         = "dev"
  kubeconfig_path                   = "../../lab/kubernetes/kubeconfig"
  container_registry_hostname       = "406661537381.dkr.ecr.us-east-1.amazonaws.com"
  deployment_image_pull_secret_name = "canopy-container-registry-credential"

  default_token = "default-token-6s4dn"

  common_labels = {
    "app.kubernetes.io/customer"    = "Sapience"
	  "app.kubernetes.io/product"     = "Sapience"
	  "app.kubernetes.io/environment" = "Dev"
	  "app.kubernetes.io/component"   = "Canopy"
	  "app.kubernetes.io/managed-by"  = "Terraform"
  }
}

module "eventpipeline_leaf_broker" {
  source = "../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.kubeconfig_path}"

  name      = "eventpipeline-leaf-broker"
  namespace = "${local.namespace}"

  deployment_image             = "${local.container_registry_hostname}/eventpipeline-leaf-broker:1.2.3.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "1024M"
          cpu = "250m"
        }
      ]
    }
  ]

  default_token = "${local.default_token}"

  deployment_env = [
    {
      name = "CANOPY_DATABASE_USERNAME"
      value_from = [
        {
          secret_key_ref = [
            {
              name = "eventpipeline-leaf-broker"
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
              name = "eventpipeline-leaf-broker"
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
      type = "LoadBalancer"
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

      load_balancer_source_ranges = [ 
        "50.20.0.62/32",     # Banyan office
        "24.99.117.169/32",  # Ardis home
        "47.187.167.223/32"  # Sapience office
      ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "canopy_user_service" {
  source = "../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.kubeconfig_path}"

  name      = "canopy-user-service"
  namespace = "${local.namespace}"

  deployment_image             = "${local.container_registry_hostname}/canopy-user-service:1.3.4.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "512M"
          cpu = "250m"
        }
      ]
    }
  ]

  default_token = "${local.default_token}"

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
      type = "LoadBalancer"
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

      load_balancer_source_ranges = [ 
        "50.20.0.62/32",     # Banyan office
        "24.99.117.169/32",  # Ardis home
        "47.187.167.223/32"  # Sapience office
      ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "canopy_hierarchy_service" {
  source = "../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.kubeconfig_path}"

  name      = "canopy-hierarchy-service"
  namespace = "${local.namespace}"

  deployment_image             = "${local.container_registry_hostname}/canopy-hierarchy-service:1.4.8.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "256M"
        }
      ]
    }
  ]

  default_token = "${local.default_token}"

  service_spec = [
    {
      type = "LoadBalancer"
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

      load_balancer_source_ranges = [ 
        "50.20.0.62/32",     # Banyan office
        "24.99.117.169/32",  # Ardis home
        "47.187.167.223/32"  # Sapience office
      ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "canopy_device_service" {
  source = "../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.kubeconfig_path}"

  name      = "canopy-device-service"
  namespace = "${local.namespace}"

  deployment_image             = "${local.container_registry_hostname}/canopy-device-service:1.7.4.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "1024M"
          cpu = "250m"
        }
      ]
    }
  ]

  default_token = "${local.default_token}"

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
              name = "eventpipeline-leaf-broker"
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
      type = "LoadBalancer"
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

      load_balancer_source_ranges = [ 
        "50.20.0.62/32",     # Banyan office
        "24.99.117.169/32",  # Ardis home
        "47.187.167.223/32", # Sapience office
        "208.82.111.61/32"   # Drury hotel
      ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "eventpipeline_service" {
  source = "../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.kubeconfig_path}"

  name      = "eventpipeline-service"
  namespace = "${local.namespace}"

  deployment_image             = "${local.container_registry_hostname}/eventpipeline-service:1.2.1.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "1024M"
          cpu = "250m"
        }
      ]
    }
  ]

  default_token = "${local.default_token}"

  readiness_probe_timeout_seconds = 10
  liveness_probe_timeout_seconds  = 10

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
      type = "LoadBalancer"
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

      load_balancer_source_ranges = [ 
        "50.20.0.62/32",     # Banyan office
        "24.99.117.169/32",  # Ardis home
        "47.187.167.223/32"  # Sapience office
      ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}

module "sapience_event_hub_journal" {
  source = "../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.kubeconfig_path}"

  name      = "sapience-event-hub-journal"
  namespace = "${local.namespace}"

  deployment_image             = "${local.container_registry_hostname}/sapience-event-hub-journal:1.0.0-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.deployment_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "512M"
        }
      ]
    }
  ]

  default_token = "${local.default_token}"

  deployment_env = [
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
      type = "LoadBalancer"
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

      load_balancer_source_ranges = [ 
        "50.20.0.62/32",     # Banyan office
        "24.99.117.169/32",  # Ardis home
        "47.187.167.223/32"  # Sapience office
      ]
    }
  ]

  labels = "${merge(
    local.common_labels,
    map()
  )}"
}