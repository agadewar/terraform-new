terraform {
  backend "azurerm" {
    key = "sapience.environment.dev.canopy.terraform.tfstate"
  }
}

provider "kubernetes" {
  version = "1.5.0"
  config_path = "${local.config_path}"
}

locals {
  namespace                         = "${var.environment}"
  config_path                       = "../../../components/kubernetes/kubeconfig"
  
  canopy_container_registry_image_pull_secret_name   = "canopy-container-registry-credential"
  sapience_container_registry_image_pull_secret_name = "sapience-container-registry-credential"

  common_labels = {
    "app.kubernetes.io/customer"    = "${var.realm_common_tags["Customer"]}"
	  "app.kubernetes.io/product"     = "${var.realm_common_tags["Product"]}"
    "app.kubernetes.io/realm"       = "${var.realm_common_tags["Realm"]}"
	  "app.kubernetes.io/environment" = "${var.environment_common_tags["Environment"]}"
	  "app.kubernetes.io/component"   = "Canopy"
	  "app.kubernetes.io/managed-by"  = "${var.realm_common_tags["ManagedBy"]}"
  }
}

data "terraform_remote_state" "kubernetes_namespace" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
    container_name       = "${var.backend_container_name}"
    key                  = "sapience.environment.${var.environment}.kubernetes-namespace.terraform.tfstate"
  }
}

data "terraform_remote_state" "service_bus" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
    container_name       = "${var.backend_container_name}"
    key                  = "sapience.environment.${var.environment}.service-bus.terraform.tfstate"
  }
}

data "terraform_remote_state" "database" {
  backend = "azurerm"

  config {
    access_key           = "${var.backend_access_key}"
    storage_account_name = "${var.backend_storage_account_name}"
    container_name       = "${var.backend_container_name}"
    key                  = "sapience.environment.${var.environment}.database.terraform.tfstate"
  }
}

data "template_file" "global_properties" {
  template = "${file("templates/global.properties.tpl")}"

  vars {
     environment = "${var.environment}"
  }
}

data "template_file" "sapience_container_registry_credential" {
  template = "${file("templates/dockerconfigjson.tpl")}"

  vars {
     server   = "${var.sapience_container_registry_hostname}"
     username = "${var.sapience_container_registry_username}"
     password = "${var.sapience_container_registry_password}"
  }
}

resource "kubernetes_secret" "sapience_container_registry_credential" {
  metadata {
    name      = "${local.sapience_container_registry_image_pull_secret_name}"
    namespace = "${local.namespace}"
  }

  data {
    ".dockerconfigjson" = "${data.template_file.sapience_container_registry_credential.rendered}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_config_map" "eventpipeline_leaf_broker" {
  metadata {
    name      = "eventpipeline-leaf-broker"
    namespace = "${local.namespace}"
  }

  data {
    "global.properties"      = "${data.template_file.global_properties.rendered}"
    "application.properties" = "${file("files/eventpipeline-leaf-broker.properties")}"
  }
}

resource "kubernetes_secret" "eventpipeline_leaf_broker" {
  metadata {
    name      = "eventpipeline-leaf-broker"
    namespace = "${local.namespace}"
  }

  data {
    "canopy.amqp.password"     = "${data.terraform_remote_state.service_bus.servicebus_namespace_default_primary_key}"
    "canopy.database.username" = "${var.sql_server_administrator_login}"
    "canopy.database.password" = "${var.sql_server_administrator_password}"
  }

  type = "Opaque"
}

module "eventpipeline_leaf_broker" {
  # depends_on = [ "kubernetes_config_map.eventpipeline_leaf_broker", "kubernetes_secret.eventpipeline_leaf_broker" ]

  source = "../../../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "eventpipeline-leaf-broker"
  namespace = "${local.namespace}"

  deployment_image                  = "${var.canopy_container_registry_hostname}/eventpipeline-leaf-broker:1.2.3.docker-SNAPSHOT"
  deployment_replicas               = 1
  deployment_image_pull_policy      = "Always"
  deployment_image_pull_secret_name = "${local.canopy_container_registry_image_pull_secret_name}"

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

  default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"

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

resource "kubernetes_config_map" "canopy_user_service" {
  metadata {
    name      = "canopy-user-service"
    namespace = "${local.namespace}"
  }

  data {
    "global.properties"      = "${data.template_file.global_properties.rendered}"
    "application.properties" = "${file("files/canopy-user-service.properties")}"
  }
}

resource "kubernetes_secret" "canopy_user_service" {
  metadata {
    name      = "canopy-user-service"
    namespace = "${local.namespace}"
  }

  data {
    "canopy.amqp.password"     = "${data.terraform_remote_state.service_bus.servicebus_namespace_default_primary_key}"
    "canopy.database.username" = "${var.sql_server_administrator_login}"
    "canopy.database.password" = "${var.sql_server_administrator_password}"
  }

  type = "Opaque"
}

module "canopy_user_service" {
  source = "../../../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "canopy-user-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/canopy-user-service:1.3.4.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.canopy_container_registry_image_pull_secret_name}"

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

  default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"

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

data "template_file" "gremlin_cosmos" {
  template = "${file("templates/gremlin-cosmos.yaml.tpl")}"

  vars {
     environment                      = "${var.environment}"
     canopy_hierarchy_cosmos_password = "${data.terraform_remote_state.database.canopy_hierarchy_cosmos_password}"
  }
}

resource "kubernetes_config_map" "canopy_hierarchy_service" {
  metadata {
    name      = "canopy-hierarchy-service"
    namespace = "${local.namespace}"
  }

  data {
    "global.properties"      = "${data.template_file.global_properties.rendered}"
    "application.properties" = "${file("files/canopy-hierarchy-service.properties")}"
    "gremlin.yaml"           = "${data.template_file.gremlin_cosmos.rendered}"
  }
}

resource "kubernetes_secret" "canopy_hierarchy_service" {
  metadata {
    name      = "canopy-hierarchy-service"
    namespace = "${local.namespace}"
  }

  data {}

  type = "Opaque"
}

module "canopy_hierarchy_service" {
  source = "../../../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "canopy-hierarchy-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/canopy-hierarchy-service:1.4.8.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.canopy_container_registry_image_pull_secret_name}"

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

  default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"

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

resource "kubernetes_config_map" "canopy_device_service" {
  metadata {
    name      = "canopy-device-service"
    namespace = "${local.namespace}"
  }

  data {
    "global.properties"      = "${data.template_file.global_properties.rendered}"
    "application.properties" = "${file("files/canopy-device-service.properties")}"
  }
}

resource "kubernetes_secret" "canopy_device_service" {
  metadata {
    name      = "canopy-device-service"
    namespace = "${local.namespace}"
  }

  data {
    "canopy.amqp.password"     = "${data.terraform_remote_state.service_bus.servicebus_namespace_default_primary_key}"
    "canopy.database.username" = "${var.sql_server_administrator_login}"
    "canopy.database.password" = "${var.sql_server_administrator_password}"
    "google.api.key"           = "${var.google_api_key}"
  }

  type = "Opaque"
}

module "canopy_device_service" {
  source = "../../../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "canopy-device-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/canopy-device-service:1.7.4.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.canopy_container_registry_image_pull_secret_name}"

  resources = [
    {
      requests = [
        {
          memory = "1536M"
          cpu = "150m"
        }
      ]
    }
  ]

  default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"

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

resource "kubernetes_config_map" "eventpipeline_service" {
  metadata {
    name      = "eventpipeline-service"
    namespace = "${local.namespace}"
  }

  data {
    "global.properties"      = "${data.template_file.global_properties.rendered}"
    "application.properties" = "${file("files/eventpipeline-service.properties")}"
  }
}

resource "kubernetes_secret" "eventpipeline_service" {
  metadata {
    name      = "eventpipeline-service"
    namespace = "${local.namespace}"
  }

  data {
    "canopy.amqp.password"     = "${data.terraform_remote_state.service_bus.servicebus_namespace_default_primary_key}"
    "canopy.database.username" = "${var.sql_server_administrator_login}"
    "canopy.database.password" = "${var.sql_server_administrator_password}"
  }

  type = "Opaque"
}

module "eventpipeline_service" {
  source = "../../../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "eventpipeline-service"
  namespace = "${local.namespace}"

  deployment_image             = "${var.canopy_container_registry_hostname}/eventpipeline-service:1.2.2.docker-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${local.canopy_container_registry_image_pull_secret_name}"

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

  default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"

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


resource "kubernetes_config_map" "eventpipeline_registry" {
  metadata {
    name      = "eventpipeline-registry"
    namespace = "${local.namespace}"
  }

  data {
    "global.properties"      = "${data.template_file.global_properties.rendered}"
  }
}

resource "kubernetes_secret" "eventpipeline_registry" {
  metadata {
    name      = "eventpipeline-registry"
    namespace = "${local.namespace}"
  }

  data {
  }

  type = "Opaque"
}

module "eventpipeline_registry" {
  source = "../../../../../../terraform-canopy-service-module/"

  kubeconfig_path = "${local.config_path}"

  name      = "eventpipeline-registry"
  namespace = "${local.namespace}"

  deployment_image             = "${var.sapience_container_registry_hostname}/eventpipeline-registry:1.0.0-SNAPSHOT"
  deployment_replicas          = 1
  deployment_image_pull_policy = "Always"
  deployment_image_pull_secret_name = "${kubernetes_secret.sapience_container_registry_credential.metadata.0.name}"   # don't use the local value string here... we need a dependency on the secret being created

  resources = [
    {
      requests = [
        {
          memory = "256M"
          cpu = "10m"
        }
      ]
    }
  ]

  default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"

  deployment_env = [
  #   {
  #     name = "CANOPY_AMQP_PASSWORD"
  #     value_from = [
  #       {
  #         secret_key_ref = [
  #           {
  #             name = "sapience-event-hub-journal"
  #             key = "canopy.amqp.password"
  #           }
  #         ]
  #       }
  #     ]
  #   },
  #  {
  #     name = "CANOPY_EVENT_HUB_PASSWORD"
  #     value_from = [
  #       {
  #         secret_key_ref = [
  #           {
  #             name = "sapience-event-hub-journal"
  #             key = "canopy.event-hub.password"
  #           }
  #         ]
  #       }
  #     ]
  #   } 
  ]

  service_spec = [
    {
      # type = "LoadBalancer"
      selector {
        "app.kubernetes.io/name" = "eventpipeline-registry"
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
