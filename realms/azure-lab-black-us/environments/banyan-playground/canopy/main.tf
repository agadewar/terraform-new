terraform {
  backend "azurerm" {
    key = "black/canopy.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
}

provider "aws" {
  alias = "banyan"

  assume_role {
    role_arn = "arn:aws:iam::603974233842:role/banyanhills.com-manage-route53"
  }

  version = "2.20.0"
  region = "us-east-1"
  profile = "banyan-lab"
}

provider "kubernetes" {
  version     = "1.9.0"
  config_path = local.config_path
}

locals {
  namespace   = var.environment
  config_path = "../../../components/kubernetes/.local/kubeconfig"

  canopy_container_registry_image_pull_secret_name   = "canopy-container-registry-credential"
  sapience_container_registry_image_pull_secret_name = "sapience-container-registry-credential"

  common_labels = {
    "sapienceanalytics.com/customer"    = replace(lower(var.realm_common_tags["Customer"]), " ", "-")
    "sapienceanalytics.com/product"     = replace(lower(var.realm_common_tags["Product"]), " ", "-")
    "sapienceanalytics.com/realm"       = replace(lower(var.realm_common_tags["Realm"]), " ", "-")
    "sapienceanalytics.com/environment" = replace(lower(var.environment_common_tags["Environment"]), " ", "-")
    // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
    //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
    "sapienceanalytics.com/component"  = "canopy"
    "sapienceanalytics.com/managed-by" = replace(lower(var.realm_common_tags["ManagedBy"]), " ", "-")
  }
}

data "local_file" "default_token_secret_name" {
  filename = "../kubernetes-namespace/.local/default_token_secret_name.out"
}

# data "terraform_remote_state" "kubernetes_namespace" {
#   backend = "azurerm"

#   config = {
#     access_key           = var.realm_backend_access_key
#     storage_account_name = var.realm_backend_storage_account_name
#     container_name       = "environment-${var.environment}"
#     key                  = "kubernetes-namespace.tfstate"
#   }
# }

data "terraform_remote_state" "container_registry" {
  backend = "azurerm"
  config = {
    access_key           = var.global_realm_backend_access_key
    storage_account_name = var.global_realm_backend_storage_account_name
    container_name       = var.global_realm_backend_container_name
    key                  = "container-registry.tfstate"
  }
}

data "terraform_remote_state" "service_bus" {
  backend = "azurerm"

  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = var.env_backend_container_name
    key                  = "service-bus.tfstate"
  }
}

data "terraform_remote_state" "database" {
  backend = "azurerm"

  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = "azure-us-dev"                            ### NOTE - this is hard-coded to "azure-us-dev", as we are not standing up a database specifically for this namespace
    key                  = "database.tfstate"
  }
}

data "terraform_remote_state" "data_lake" {
  backend = "azurerm"

  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
    container_name       = var.env_backend_container_name
    key                  = "data-lake.tfstate"
  }
}

# data "terraform_remote_state" "ingress_controller" {
#   backend = "azurerm"
#   config = {
#     access_key           = "${var.realm_backend_access_key}"
#     storage_account_name = "${var.realm_backend_storage_account_name}"
# 	  container_name       = "${var.realm_backend_container_name}"
#     key                  = "black/ingress-controller.tfstate"
#   }
# }

data "template_file" "global_properties" {
  template = file("templates/global.properties.tpl")

  vars = {
    realm                   = var.realm
    environment             = var.environment
    kafka_bootstrap_servers = var.kafka_bootstrap_servers
  }
}

data "template_file" "sapience_container_registry_credential" {
  template = file("templates/dockerconfigjson.tpl")

  vars = {
    # server   = var.sapience_container_registry_hostname
    # username = var.sapience_container_registry_username
    # password = var.sapience_container_registry_password
    server   = data.terraform_remote_state.container_registry.outputs.login_server
    username = data.terraform_remote_state.container_registry.outputs.admin_username
    password = data.terraform_remote_state.container_registry.outputs.admin_password
  }
}

resource "kubernetes_secret" "sapience_container_registry_credential" {
  metadata {
    name      = local.sapience_container_registry_image_pull_secret_name
    namespace = local.namespace
  }

  data = {
    ".dockerconfigjson" = data.template_file.sapience_container_registry_credential.rendered
  }

  type = "kubernetes.io/dockerconfigjson"
}

# resource "kubernetes_config_map" "eventpipeline_leaf_broker" {
#   metadata {
#     name      = "eventpipeline-leaf-broker"
#     namespace = local.namespace
#   }

#   data = {
#     "global.properties"      = data.template_file.global_properties.rendered
#     "application.properties" = file("files/eventpipeline-leaf-broker.properties")
#   }
# }

# resource "kubernetes_secret" "eventpipeline_leaf_broker" {
#   metadata {
#     name      = "eventpipeline-leaf-broker"
#     namespace = local.namespace
#   }

#   data = {
#     "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
#     "canopy.database.username" = var.sql_server_administrator_login
#     "canopy.database.password" = var.sql_server_administrator_password
#   }

#   type = "Opaque"
# }

# module "eventpipeline_leaf_broker" {
#   # depends_on = [ "kubernetes_config_map.eventpipeline_leaf_broker", "kubernetes_secret.eventpipeline_leaf_broker" ]

#   source = "../../../../../../terraform-canopy-service-module/"

#   kubeconfig_path = local.config_path

#   name      = "eventpipeline-leaf-broker"
#   namespace = local.namespace

#   deployment_image                  = "${var.canopy_container_registry_hostname}/eventpipeline-leaf-broker:1.2.3.docker-SNAPSHOT"
#   deployment_replicas               = 1
#   deployment_image_pull_policy      = "Always"
#   deployment_image_pull_secret_name = local.canopy_container_registry_image_pull_secret_name

#   resources = [
#     {
#       requests = [
#         {
#           memory = "768M"
#           cpu    = "150m"
#         },
#       ]
#     },
#   ]

#   default_token = data.terraform_remote_state.kubernetes_namespace.outputs.default_token_secret_name

#   deployment_env = [
#     {
#       name = "CANOPY_DATABASE_USERNAME"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-leaf-broker"
#               key  = "canopy.database.username"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_DATABASE_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-leaf-broker"
#               key  = "canopy.database.password"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_AMQP_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-leaf-broker"
#               key  = "canopy.amqp.password"
#             },
#           ]
#         },
#       ]
#     },
#   ]

#   service_spec = [
#     {
#       // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
#       //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
#       selector = {
#         "sapienceanalytics.com/name" = "eventpipeline-leaf-broker"
#       }
#       port = [
#         {
#           name        = "application"
#           port        = 80
#           target_port = 8080
#         },
#       ]
#     },
#   ]

#   labels = merge(local.common_labels, {})
# }

# resource "kubernetes_config_map" "canopy_user_service" {
#   metadata {
#     name      = "canopy-user-service"
#     namespace = local.namespace
#   }

#   data = {
#     "global.properties"      = data.template_file.global_properties.rendered
#     "application.properties" = file("files/canopy-user-service.properties")
#   }
# }

# resource "kubernetes_secret" "canopy_user_service" {
#   metadata {
#     name      = "canopy-user-service"
#     namespace = local.namespace
#   }

#   data = {
#     "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
#     "canopy.database.username" = var.sql_server_administrator_login
#     "canopy.database.password" = var.sql_server_administrator_password
#   }

#   type = "Opaque"
# }

# module "canopy_user_service" {
#   source = "../../../../../../terraform-canopy-service-module/"

#   kubeconfig_path = local.config_path

#   name      = "canopy-user-service"
#   namespace = local.namespace

#   deployment_image                  = "${var.canopy_container_registry_hostname}/canopy-user-service:1.3.4.docker-SNAPSHOT"
#   deployment_replicas               = 1
#   deployment_image_pull_policy      = "Always"
#   deployment_image_pull_secret_name = local.canopy_container_registry_image_pull_secret_name

#   resources = [
#     {
#       requests = [
#         {
#           memory = "512M"
#           cpu    = "150m"
#         },
#       ]
#     },
#   ]

#   default_token = data.terraform_remote_state.kubernetes_namespace.outputs.default_token_secret_name

#   deployment_env = [
#     {
#       name = "CANOPY_DATABASE_USERNAME"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "canopy-user-service"
#               key  = "canopy.database.username"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_DATABASE_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "canopy-user-service"
#               key  = "canopy.database.password"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_AMQP_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-leaf-broker"
#               key  = "canopy.amqp.password"
#             },
#           ]
#         },
#       ]
#     },
#   ]

#   service_spec = [
#     {
#       // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
#       //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
#       selector = {
#         "sapienceanalytics.com/name" = "canopy-user-service"
#       }
#       port = [
#         {
#           name        = "application"
#           port        = 80
#           target_port = 8080
#         },
#         {
#           name = "hazelcast"
#           port = 5701
#         },
#       ]
#     },
#   ]

#   labels = merge(local.common_labels, {})
# }

# data "template_file" "gremlin_cosmos" {
#   template = file("templates/gremlin-cosmos.yaml.tpl")

#   vars = {
#     environment                      = var.environment
#     canopy_hierarchy_cosmos_password = data.terraform_remote_state.database.outputs.canopy_hierarchy_cosmos_password
#   }
# }

# resource "kubernetes_config_map" "canopy_hierarchy_service" {
#   metadata {
#     name      = "canopy-hierarchy-service"
#     namespace = local.namespace
#   }

#   data = {
#     "global.properties"      = data.template_file.global_properties.rendered
#     "application.properties" = file("files/canopy-hierarchy-service.properties")
#     "gremlin.yaml"           = data.template_file.gremlin_cosmos.rendered
#   }
# }

# resource "kubernetes_secret" "canopy_hierarchy_service" {
#   metadata {
#     name      = "canopy-hierarchy-service"
#     namespace = local.namespace
#   }

#   data = {}

#   type = "Opaque"
# }

# module "canopy_hierarchy_service" {
#   source = "../../../../../../terraform-canopy-service-module/"

#   kubeconfig_path = local.config_path

#   name      = "canopy-hierarchy-service"
#   namespace = local.namespace

#   deployment_image                  = "${var.canopy_container_registry_hostname}/canopy-hierarchy-service:1.4.8.docker-SNAPSHOT"
#   deployment_replicas               = 1
#   deployment_image_pull_policy      = "Always"
#   deployment_image_pull_secret_name = local.canopy_container_registry_image_pull_secret_name

#   resources = [
#     {
#       requests = [
#         {
#           memory = "256M"
#           cpu    = "150m"
#         },
#       ]
#     },
#   ]

#   default_token = data.terraform_remote_state.kubernetes_namespace.outputs.default_token_secret_name

#   service_spec = [
#     {
#       // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
#       //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
#       selector = {
#         "sapienceanalytics.com/name" = "canopy-hierarchy-service"
#       }
#       port = [
#         {
#           name        = "application"
#           port        = 80
#           target_port = 8080
#         },
#       ]
#     },
#   ]

#   labels = merge(local.common_labels, {})
# }

# resource "kubernetes_config_map" "canopy_device_service" {
#   metadata {
#     name      = "canopy-device-service"
#     namespace = local.namespace
#   }

#   data = {
#     "global.properties"      = data.template_file.global_properties.rendered
#     "application.properties" = file("files/canopy-device-service.properties")
#   }
# }

# resource "kubernetes_secret" "canopy_device_service" {
#   metadata {
#     name      = "canopy-device-service"
#     namespace = local.namespace
#   }

#   data = {
#     "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
#     "canopy.database.username" = var.sql_server_administrator_login
#     "canopy.database.password" = var.sql_server_administrator_password
#     "google.api.key"           = var.google_api_key
#   }

#   type = "Opaque"
# }

# module "canopy_device_service" {
#   source = "../../../../../../terraform-canopy-service-module/"

#   kubeconfig_path = local.config_path

#   name      = "canopy-device-service"
#   namespace = local.namespace

#   deployment_image                  = "${var.canopy_container_registry_hostname}/canopy-device-service:1.7.4.docker-SNAPSHOT"
#   deployment_replicas               = 1
#   deployment_image_pull_policy      = "Always"
#   deployment_image_pull_secret_name = local.canopy_container_registry_image_pull_secret_name

#   resources = [
#     {
#       requests = [
#         {
#           memory = "1536M"
#           cpu    = "150m"
#         },
#       ]
#     },
#   ]

#   default_token = data.terraform_remote_state.kubernetes_namespace.outputs.default_token_secret_name

#   deployment_env = [
#     {
#       name = "CANOPY_DATABASE_USERNAME"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "canopy-device-service"
#               key  = "canopy.database.username"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_DATABASE_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "canopy-device-service"
#               key  = "canopy.database.password"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_AMQP_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "canopy-device-service"
#               key  = "canopy.amqp.password"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "GOOGLE_API_KEY"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "canopy-device-service"
#               key  = "google.api.key"
#             },
#           ]
#         },
#       ]
#     },
#   ]

#   service_spec = [
#     {
#       // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
#       //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
#       selector = {
#         "sapienceanalytics.com/name" = "canopy-device-service"
#       }
#       port = [
#         {
#           name        = "application"
#           port        = 80
#           target_port = 8080
#         },
#       ]
#     },
#   ]

#   labels = merge(local.common_labels, {})
# }

# resource "kubernetes_config_map" "eventpipeline_service" {
#   metadata {
#     name      = "eventpipeline-service"
#     namespace = local.namespace
#   }

#   data = {
#     "global.properties"      = data.template_file.global_properties.rendered
#     "application.properties" = file("files/eventpipeline-service.properties")
#   }
# }

# resource "kubernetes_secret" "eventpipeline_service" {
#   metadata {
#     name      = "eventpipeline-service"
#     namespace = local.namespace
#   }

#   data = {
#     "canopy.amqp.password"     = data.terraform_remote_state.service_bus.outputs.servicebus_namespace_default_primary_key
#     "canopy.database.username" = var.sql_server_administrator_login
#     "canopy.database.password" = var.sql_server_administrator_password
#   }

#   type = "Opaque"
# }

# module "eventpipeline_service" {
#   source = "../../../../../../terraform-canopy-service-module/"

#   kubeconfig_path = local.config_path

#   name      = "eventpipeline-service"
#   namespace = local.namespace

#   deployment_image                  = "${var.canopy_container_registry_hostname}/eventpipeline-service:1.2.2.docker-SNAPSHOT"
#   deployment_replicas               = 1
#   deployment_image_pull_policy      = "Always"
#   deployment_image_pull_secret_name = local.canopy_container_registry_image_pull_secret_name

#   resources = [
#     {
#       requests = [
#         {
#           memory = "768M"
#           cpu    = "150m"
#         },
#       ]
#     },
#   ]

#   default_token = data.terraform_remote_state.kubernetes_namespace.outputs.default_token_secret_name

#   readiness_probe_timeout_seconds = 10
#   liveness_probe_timeout_seconds  = 10

#   deployment_env = [
#     {
#       name = "CANOPY_DATABASE_USERNAME"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-service"
#               key  = "canopy.database.username"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_DATABASE_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-service"
#               key  = "canopy.database.password"
#             },
#           ]
#         },
#       ]
#     },
#     {
#       name = "CANOPY_AMQP_PASSWORD"
#       value_from = [
#         {
#           secret_key_ref = [
#             {
#               name = "eventpipeline-service"
#               key  = "canopy.amqp.password"
#             },
#           ]
#         },
#       ]
#     },
#   ]

#   service_spec = [
#     {
#       // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
#       //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
#       selector = {
#         "sapienceanalytics.com/name" = "eventpipeline-service"
#       }
#       port = [
#         {
#           name        = "application"
#           port        = 80
#           target_port = 8080
#         },
#       ]
#     },
#   ]

#   labels = merge(local.common_labels, {})
# }

# # resource "kubernetes_config_map" "eventpipeline_registry" {
# #   metadata {
# #     name      = "eventpipeline-registry"
# #     namespace = "${local.namespace}"
# #   }
# #   data {
# #     "global.properties"      = "${data.template_file.global_properties.rendered}"
# #   }
# # }
# # resource "kubernetes_secret" "eventpipeline_registry" {
# #   metadata {
# #     name      = "eventpipeline-registry"
# #     namespace = "${local.namespace}"
# #   }
# #   data {
# #   }
# #   type = "Opaque"
# # }
# # module "eventpipeline_registry" {
# #   source = "../../../../../../terraform-canopy-service-module/"
# #   kubeconfig_path = "${local.config_path}"
# #   name      = "eventpipeline-registry"
# #   namespace = "${local.namespace}"
# #   deployment_image             = "${var.sapience_container_registry_hostname}/eventpipeline-registry:1.0.0-SNAPSHOT"
# #   deployment_replicas          = 1
# #   deployment_image_pull_policy = "Always"
# #   deployment_image_pull_secret_name = "${kubernetes_secret.sapience_container_registry_credential.metadata.0.name}"   # don't use the local value string here... we need a dependency on the secret being created
# #   resources = [
# #     {
# #       requests = [
# #         {
# #           memory = "256M"
# #           cpu = "10m"
# #         }
# #       ]
# #     }
# #   ]
# #   default_token = "${data.terraform_remote_state.kubernetes_namespace.default_token_secret_name}"
# #   deployment_env = []
# #   service_spec = [
# #     {
# #       // TODO (PBI-12532) - once "terraform-provider-kubernetes" commit "4fa027153cf647b2679040b6c4653ef24e34f816" is merged, change the prefix on the
# #       //                    below labels to "app.kubernetes.io" - see: https://kubernetes.io/docs/concepts/overview/working-with-objects/common-labels/#labels
# #       selector {
# #         "sapienceanalytics.com/name" = "eventpipeline-registry"
# #       }
# #       port = [
# #         {
# #           name        = "application"
# #           port        = 80
# #           target_port = 8080
# #         }
# #       ]
# #     }
# #   ]
# #   labels = "${merge(
# #     local.common_labels,
# #     map()
# #   )}"
# # }
