terraform {
  backend "azurerm" {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.ambassador.terraform.tfstate"
  }
}

provider "azurerm" {
  version = "1.20.0"
  subscription_id = "${local.subscription_id}"
}

provider "kubernetes" {
    config_path = "${local.config_path}"
}

# provider "helm" {
#   kubernetes {
#     config_path = "${local.config_path}"
#   }

#   #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
#   service_account = "tiller"
# }

data "terraform_remote_state" "resource_group" {
  backend = "azurerm"
  config {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.lab.resource-group.terraform.tfstate"
  }
}

data "terraform_remote_state" "dns" {
  backend = "azurerm"
  config {
    access_key           = "f6c42IJmnIymEm3ziDX2GdgrrqUVNSV82CX5/2LWcrc4bwHnCJWhPHHzQFRaQqoLLjZIle9+BsfFguI4epFNeA=="
    storage_account_name = "sapiencetfstatelab"
	  container_name       = "tfstate"
    key                  = "sapience.dev.dns.terraform.tfstate"
  }
}

locals {
  subscription_id = "a450fc5d-cebe-4c62-b61a-0069ab902ee7"

  config_path = "../../lab/kubernetes/kubeconfig"
  namespace = "dev"
  
  common_tags = {
    Customer = "Sapience"
    Product = "Sapience"
    Environment = "Dev"
    Component = "Ambassador"
    ManagedBy = "Terraform"
  }
}

# resource "kubernetes_cluster_role" "traefik_ingress_controller" {
#     metadata {
#         name = "traefik-ingress-controller"
#     }

#     rule {
#         api_groups = [""]
#         resources  = ["services", "endpoints", "secrets"]
#         verbs      = ["get", "list", "watch"]
#     }

#     rule {
#         api_groups = ["extensions"]
#         resources  = ["ingresses"]
#         verbs      = ["get", "list", "watch"]
#     }
# }

# resource "kubernetes_cluster_role_binding" "traefik_ingress_controller" {
#     metadata {
#         name = "traefik-ingress-controller"
#     }
#     role_ref {
#         api_group = "rbac.authorization.k8s.io"
#         kind = "ClusterRole"
#         name = "traefik-ingress-controller"
#     }
#     subject {
#         kind = "ServiceAccount"
#         name = "traefik-ingress-controller"
#         namespace = "kube-system"
#     }
# }

# resource "kubernetes_service_account" "traefik_ingress_controller" {
#   metadata {
#     name = "traefik-ingress-controller"
#     namespace = "kube-system"
#   }
#   # secret {
#   #   name = "${kubernetes_secret.example.metadata.0.name}"
#   # }
# }


# resource "kubernetes_daemonset" "traefik_ingress_controller" {
#   metadata {
#     name = "traefik-ingress-controller"
#     namespace = "kube-system"
#     labels {
#       k8s-app = "traefik-ingress-lb"
#     }
#   }

#   spec {
#     selector {
#       match_labels {
#         k8s-app = "traefik-ingress-lb"
#         name    = "traefik-ingress-lb"
#       }
#     }

#     template {
#       metadata {
#         # namespace = "something"
#         labels {
#           k8s-app = "traefik-ingress-lb"
#           name    = "traefik-ingress-lb"
#         }
#       }

#       spec {
#         service_account_name = "traefik-ingress-controller"
#         termination_grace_period_seconds = 60

#         container {
#           image = "traefik"
#           name  = "traefik-ingress-lb"

#           port {
#             name           = "http"
#             container_port = 80
#             host_port      = 80
#           }

#           port {
#             name = "admin"
#             container_port = 8080
#           }

#           security_context {
#             capabilities {
#               drop = [ "ALL" ]
#               add  = [ "NET_BIND_SERVICE" ]
#             }
#           }

#           args = []
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "traefik_ingress_service" {
#   metadata {
#     name = "traefik-ingress-service"
#     namespace = "kube-system"
#   }
#   spec {
#     selector {
#       k8s-app = "traefik-ingress-lb"
#     }
#     # session_affinity = "ClientIP"
#     port {
#       protocol = "TCP"
#       port = 80
#       name = "web"
#     }
#     port {
#       protocol = "TCP"
#       port = 8080
#       name = "admin"
#     }

#     # type = "LoadBalancer"
#   }
# }

# resource "kubernetes_service" "traefik_web_ui" {
#   metadata {
#     name = "traefik-web-ui"
#     namespace = "kube-system"
#   }
#   spec {
#     selector {
#       k8s-app = "traefik-ingress-lb"
#     }
#     # session_affinity = "ClientIP"
#     port {
#       name = "web"
#       port = 80
#       target_port = 8080
#     }

#     # type = "LoadBalancer"
#   }
# }

# See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
# data "template_file" "ambassador_rbac" {
#   template = "${file("templates/ambassador-rbac.yaml.tpl")}"
#   # vars {
#   #   HOSTNAME ="api.${local.namespace}.sapience.net"
#   # }
# }

# resource "null_resource" "ambassador_rbac" {
#   triggers = {
#     manifest_sha1 = "${sha1("${data.template_file.ambassador_rbac.rendered}")}"
#   }

#   provisioner "local-exec" {
#     command = "kubectl apply --kubeconfig=${local.config_path} -f -<<EOF\n${data.template_file.ambassador_rbac.rendered}\nEOF"
#   }
# }

# See: https://www.getambassador.io/user-guide/getting-started/#1-deploying-ambassador
resource "null_resource" "ambassador_rbac" {
  triggers = {
    manifest_sha1 = "${sha1("${file("files/ambassador-rbac.yaml")}")}"
    timestamp = "${timestamp()}"   # DELETE ME
  }

  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${local.config_path} -n dev -f -<<EOF\n${file("files/ambassador-rbac.yaml")}\nEOF"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#2-defining-the-ambassador-service
resource "kubernetes_service" "ambassador" {
  metadata {
    name = "ambassador"
    namespace = "dev"
  }

  spec {
    selector {
      service = "ambassador"
    }
    # session_affinity = "ClientIP"
    port {
      # name = "web"
      port = 80
      # target_port = 8080
    }

    # external_traffic_policy = "Local"
    type = "LoadBalancer"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#2-defining-the-ambassador-service
# See: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/59
resource "null_resource" "patch_ambassador_service" {
  depends_on = [ "kubernetes_service.ambassador" ]

  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl patch --kubeconfig=${local.config_path} svc ambassador -n dev -p '{\"spec\":{\"externalTrafficPolicy\":\"Local\"}}'"
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#3-creating-your-first-route
resource "kubernetes_service" "httpbin" {
  metadata {
    name = "httpbin"
    namespace = "dev"
    annotations {
      "getambassador.io/config" = <<EOF
---
apiVersion: ambassador/v1
kind:  Mapping
name:  httpbin_mapping
prefix: /httpbin/
service: httpbin.org:80
host_rewrite: httpbin.org
EOF
    }
  }

  spec {
    port {
      name = "httpbin"
      port = 80
    }
  }
}

# See: https://www.getambassador.io/user-guide/getting-started/#5-adding-a-service
resource "kubernetes_service" "api" {
  metadata {
    name = "api"
    namespace = "dev"
    annotations {
      "getambassador.io/config" = <<EOF
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_device_service_mapping
prefix: /device/
service: canopy-device-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_hierarchy_service_mapping
prefix: /hierarchy/
service: canopy-hierarchy-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  canopy_user_service_mapping
prefix: /user/
service: canopy-user-service
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_leaf_broker_mapping
prefix: /leafbroker/
service: eventpipeline-leaf-broker
---
apiVersion: ambassador/v1
kind:  Mapping
name:  eventpipeline_service_mapping
prefix: /eventpipeline/
service: eventpipeline-service
EOF
    }
  }

  spec {
    port {
      port = 80
    }
  }
}

resource "azurerm_dns_a_record" "api" {
  name                = "api"
  zone_name           = "${data.terraform_remote_state.dns.zone_name}"
  resource_group_name = "${data.terraform_remote_state.resource_group.resource_group_name}"
  ttl                 = 30
  records             = [ "${kubernetes_service.ambassador.load_balancer_ingress.0.ip}" ]
}
