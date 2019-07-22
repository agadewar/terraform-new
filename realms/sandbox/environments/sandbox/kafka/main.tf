terraform {
  backend "azurerm" {
    key = "kafka.tfstate"
  }
}

provider "azurerm" {
  version         = "1.30.1"

  subscription_id = var.subscription_id
  client_id       = var.service_principal_app_id
  client_secret   = var.service_principal_password
  tenant_id       = var.service_principal_tenant
}

provider "kubernetes" {
  config_path = local.config_path
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

locals {
  config_path = "../../../components/kubernetes/kubeconfig"

  namespace   = var.environment

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Kafka"
    }
  )
}

# data "terraform_remote_state" "storage_account" {
#   backend = "azurerm"

#   config = {
#     access_key           = var.realm_backend_access_key
#     storage_account_name = var.realm_backend_storage_account_name
#     container_name       = "realm-${var.realm}"
#     key                  = "storage-account.tfstate"
#   }
# }

# data "terraform_remote_state" "dns" {
#   backend = "azurerm"
#   config = {
#     access_key           = var.realm_backend_access_key
#     storage_account_name = var.realm_backend_storage_account_name
#     container_name       = "realm-global"
#     key                  = "dns.tfstate"
#   }
# }

# data "terraform_remote_state" "ingress-controller" {
#   backend = "azurerm"

#   config = {
#     access_key           = var.realm_backend_access_key
#     storage_account_name = var.realm_backend_storage_account_name
#     container_name       = "realm-${var.realm}"
#     key                  = "ingress-controller.tfstate"
#   }
# }

# data "template_file" "custom_values" {
#   template = file("templates/custom-values.yaml.tpl")

#   vars = {
#     realm                  = var.realm
#     storageAccountName     = data.terraform_remote_state.storage_account.outputs.storage_account_name
#     accessKey              = data.terraform_remote_state.storage_account.outputs.storage_account_access_key
#     whitelist-source-range = join(", ", var.spinnaker_source_ranges_allowed)
#     additional-kubeconfig-contexts = indent(
#       2,
#       join(
#         "\n",
#         formatlist("- %s", var.spinnaker_additional_kubeconfig_contexts),
#       ),
#     )
#     acr-address  = var.sapience_container_registry_hostname
#     acr-username = var.sapience_container_registry_username
#     acr-password = var.sapience_container_registry_password
#     acr-email    = var.devops_email
#   }
# }

# resource "kubernetes_namespace" "spinnaker" {
#   metadata {
#     name = local.namespace
#   }
# }

# resource "null_resource" "kubeconfig" {
#   provisioner "local-exec" {
#     # combine kubeconfigs
#     command = "mkdir -p .local && KUBECONFIG=${join(
#       ":",
#       formatlist(
#         "../../../%s/components/kubernetes/kubeconfig",
#         concat(var.spinnaker_additional_kubeconfig_contexts, [var.realm]),
#       ),
#     )} kubectl config view --merge --flatten > .local/kubeconfig"
#   }

#   provisioner "local-exec" {
#     when = destroy

#     command = "rm -f .local/kubeconfig"
#   }
# }

# data "local_file" "kubeconfig" {
#   depends_on = [null_resource.kubeconfig]

#   filename = ".local/kubeconfig"
# }

# resource "kubernetes_secret" "kubeconfig" {
#   depends_on = [null_resource.kubeconfig]

#   metadata {
#     name      = "kubeconfig"
#     namespace = local.namespace
#   }

#   data = {
#     config = data.local_file.kubeconfig.content
#   }
#   # don't use "local.config_path" here, as it may need to be a kubeconfig file comprised of multiple environments; this secret
#   # is used by the spinnaker helm chart to make Spinnaker aware of the K8S clusters it should be aware of
#   #config = "${file("${var.kubeconfig}")}"
# }

data "helm_repository" "incubator" {
  name = "incubator"
  url  = "http://storage.googleapis.com/kubernetes-charts-incubator"
}

data "template_file" "custom_values" {
  template = file("templates/custom-values.yaml.tpl")

  # vars = {
  #   # admin_password = var.monitoring_grafana_admin_password
  #   POD_IP = "10.0.78.208"
  # }
}

resource "helm_release" "kafka" {
  name      = "kafka"
  namespace = local.namespace
  chart     = "incubator/kafka"

  values = [
    data.template_file.custom_values.rendered
  ]

  timeout = 900
}

# resource "null_resource" "nginx_ingress_controller_ip" {
#   depends_on = [ "helm_release.nginx_ingress" ]

#   # triggers = {
#   #   timestamp = "${timestamp()}"
#   # }

#   provisioner "local-exec" {
#     command = "mkdir -p .local && kubectl --kubeconfig ${local.config_path} -n ${local.namespace} get services -o json | jq -j '.items[] | select(.metadata.name == \"nginx-ingress-controller\") | .status .loadBalancer .ingress [0] .ip' > .local/nginx-ingress-controller-ip"
#   }

#   provisioner "local-exec" {
#     when = "destroy"

#     command = "rm -f .local/nginx-ingress-controller-ip"
#   }
# }

# data "local_file" "nginx_ingress_controller_ip" {
#   depends_on = [ "null_resource.nginx_ingress_controller_ip" ]

#   filename = ".local/nginx-ingress-controller-ip"
# }

# resource "azurerm_dns_a_record" "spinnaker" {
#   name                = "spinnaker.${var.realm}"
#   zone_name           = data.terraform_remote_state.dns.outputs.sapienceanalytics_public_zone_name
#   resource_group_name = "Global"
#   ttl                 = 30
#   # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
#   # force an interpolation expression to be interpreted as a list by wrapping it
#   # in an extra set of list brackets. That form was supported for compatibilty in
#   # v0.11, but is no longer supported in Terraform v0.12.
#   #
#   # If the expression in the following list itself returns a list, remove the
#   # brackets to avoid interpretation as a list of lists. If the expression
#   # returns a single list item then leave it as-is and remove this TODO comment.
#   records = [data.terraform_remote_state.ingress-controller.outputs.nginx_ingress_controller_ip]
# }

# resource "kubernetes_ingress" "kafka" {
#   metadata {
#     name      = "kafka"
#     namespace = local.namespace

#     annotations = {
#       # "certmanager.k8s.io/acme-challenge-type" = "dns01"
#       # "certmanager.k8s.io/acme-dns01-provider" = "azure-dns"
#       # "certmanager.k8s.io/cluster-issuer"      = "letsencrypt-prod"
#       # "ingress.kubernetes.io/ssl-redirect"     = "true"
#       "kubernetes.io/ingress.class"            = "nginx"
#       # "kubernetes.io/tls-acme"                 = "true"
#     }
#   }

#   # spec {
#   #   rule {
#   #     host = "kafka.${var.environment}.${var.realm}.sapienceanalytics.com"
#   #     http {
#   #       path {
#   #         backend {
#   #           service_name = "kafka"
#   #           service_port = 9092
#   #         }

#   #         path = "/"
#   #       }
#   #     }
#   #   }

#   #   rule {
#   #     host = "kafka.${var.environment}.sapienceanalytics.com"
#   #     http {
#   #       path {
#   #         backend {
#   #           service_name = "kafka"
#   #           service_port = 80
#   #         }

#   #         path = "/"
#   #       }
#   #     }
#   #   }

#   #   tls {
#   #     hosts = [
#   #       "api.${var.environment}.${var.realm}.sapienceanalytics.com",
#   #       "api.${var.environment}.sapienceanalytics.com",
#   #     ]
#   #     secret_name = "ambassador-certs"
#   #   }
#   # }
# }