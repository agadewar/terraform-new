terraform {
  backend "azurerm" {
    key = "klov.tfstate"
  }
}

provider "azurerm" {
  version = "1.31.0"
  
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.service_principal_app_id}"
  client_secret   = "${var.service_principal_password}"
  tenant_id       = "${var.service_principal_tenant}"
}

provider "kubernetes" {
  config_path = "${local.config_path}"
}

data "terraform_remote_state" "container_registry" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "container-registry.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "dns.tfstate"
  }
}

data "terraform_remote_state" "ingress-controller" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "ingress-controller.tfstate"
  }
}

data "terraform_remote_state" "kubernetes" {
  backend = "azurerm"

  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
    container_name       = var.realm_backend_container_name
    key                  = "kubernetes.tfstate"
  }
}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace = "klov"
  sapience_container_registry_image_pull_secret_name = "sapience-container-registry-credential"

  common_tags = "${merge(
    var.realm_common_tags,
    map(
      "Component", "Klov Reporting Server"
    )
  )}"
}

data "template_file" "sapience_container_registry_credential" {
  template = "${file("templates/dockerconfigjson.tpl")}"

  vars = {
     server   = data.terraform_remote_state.container_registry.outputs.login_server
     username = data.terraform_remote_state.container_registry.outputs.admin_username
     password = data.terraform_remote_state.container_registry.outputs.admin_password
  }
}

resource "kubernetes_secret" "sapience_container_registry_credential" {
  metadata {
    name      = "${local.sapience_container_registry_image_pull_secret_name}"
    namespace = kubernetes_namespace.klov.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = "${data.template_file.sapience_container_registry_credential.rendered}"
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_namespace" "klov" {
  metadata {
    name = "${local.namespace}"
  }
}

resource "kubernetes_deployment" "klov" {
  depends_on = [ "kubernetes_service_account.klov" ]

  metadata {
    annotations = "${merge(
      local.common_tags
    )}"

    name = "klov"
    namespace = kubernetes_namespace.klov.metadata.0.name
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "klov"
      }
    }
    template {
      metadata {
        labels = {
          app = "klov"
        }
      }
      spec {
        service_account_name = "klov"

        security_context {
            fs_group = 1000
            run_as_user = 1000
        }

        container {
          name = "klov"
          image = "${data.terraform_remote_state.container_registry.outputs.login_server}/klov-reporting-server:latest"
          image_pull_policy = "Always"

          resources {
            requests {
              cpu    = "100m"
              memory = "1000Mi"
            }
          }

          env {
            name  = "JAVA_OPTS"
            value = "-server"
          }

          env {
            name = "spring.data.mongodb.uri"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.klov_mongodb.metadata.0.name
                key = "uri"
              }
            }
          }

          env {
            name = "server.admin.name"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.klov_server_admin.metadata.0.name
                key = "name"
              }
            }
          }

          env {
            name = "server.admin.key"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.klov_server_admin.metadata.0.name
                key = "key"
              }
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.klov_server.metadata.0.name
            }
          }

          port {
            name = "http-port"
            container_port = 8080
          }
        }
        
        image_pull_secrets {
          name = "${kubernetes_secret.sapience_container_registry_credential.metadata.0.name}"
        }
      }
    }
  }
}

resource "kubernetes_config_map" "klov_server" {
  metadata {
    name = "klov-server"
    namespace = kubernetes_namespace.klov.metadata.0.name
  }

  data = {
    "extent.api.version"                 = "community"
    "application.name"                   = "klov"
    "server.port"                        = 8080
    "spring.data.mongodb.database"       = "klov"
    "spring.data.rest.basePath"          = "/rest"
    "spring.data.rest.default-page-size" = 10
    "spring.autoconfigure.exclude"       = "org.springframework.boot.autoconfigure.session.SessionAutoConfiguration"
    "file.storage.location"              = "./upload/reports/"
  }
}

resource "kubernetes_secret" "klov_mongodb" {
  metadata {
    name      = "klov-mongodb"
    namespace = kubernetes_namespace.klov.metadata.0.name
  }

  data = {
    "uri" = azurerm_cosmosdb_account.klov.connection_strings.0
  }

  type = "Opaque"
}

resource "kubernetes_secret" "klov_server_admin" {
  metadata {
    name      = "klov-server-admin"
    namespace = kubernetes_namespace.klov.metadata.0.name
  }

  data = {
    "name" = var.klov_server_admin_name
    "key"  = var.klov_server_admin_key
  }

  type = "Opaque"
}

resource "kubernetes_service" "klov" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "klov"
    namespace = kubernetes_namespace.klov.metadata.0.name
  }

  spec {
    type = "ClusterIP"
    selector = {
      app = "klov"
    }

    port {
      name = "http"
      port = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service_account" "klov" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "klov"
    namespace = "${kubernetes_namespace.klov.metadata.0.name}"
  }
}

resource "kubernetes_cluster_role_binding" "klov" {
  metadata {
    annotations = "${merge(
      local.common_tags
    )}"
    
    name = "klov"
  }

    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "ClusterRole"
        name = "cluster-admin"
    }
    subject {
        kind = "ServiceAccount"
        name = "klov"
        namespace = kubernetes_namespace.klov.metadata.0.name
        api_group = ""
    }
}

resource "azurerm_dns_a_record" "klov" {
  name                = "klov.${var.dns_realm}.${var.region}.${var.cloud}"
  zone_name           = "${data.terraform_remote_state.dns.outputs.sapienceanalytics_public_zone_name}"
  resource_group_name = "${var.resource_group_name}"
  ttl                 = 30
  records             = [ "${data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip}" ]
}

resource "kubernetes_ingress" "klov" {
  metadata {
    name = "klov"
    namespace = kubernetes_namespace.klov.metadata.0.name

    annotations = {
      "certmanager.k8s.io/acme-challenge-type"             = "dns01"
      "certmanager.k8s.io/acme-dns01-provider"             = "azure-dns"
      "certmanager.k8s.io/cluster-issuer"                  = "letsencrypt-prod"
      "kubernetes.io/ingress.class"                        = "nginx"
      "kubernetes.io/tls-acme"                             = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "${join(", ", var.klov_source_ranges_allowed)}"
    }
  }

  spec {
    rule {
      host = "klov.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "klov"
            service_port = 8080
          }

          path = "/"
        }
      }
    }

    rule {
      host = "klov.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "klov"
            service_port = 8080
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [ 
        "klov.${var.dns_realm}.${var.region}.${var.cloud}.sapienceanalytics.com",
        "klov.sapienceanalytics.com"
      ]
      secret_name = "klov-certs"
    }
  }
}
