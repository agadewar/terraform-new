terraform {
  backend "azurerm" {
    key = "nexus.tfstate"
  }
}

provider "kubernetes" {
  config_path = local.config_path
}

# provider "helm" {
#   kubernetes {
#     config_path = local.config_path
#   }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  #service_account = "tiller"
#}

locals {
  config_path = "../kubernetes/.local/kubeconfig"
  namespace   = "nexus"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "nexus"
    },
  )
}

# resource "helm_release" "sonatype-nexus" {
#   name      = "sonatype-nexus"
#   namespace = "nexus"
#   chart     = "stable/sonatype-nexus"
# }

resource "null_resource" "sonatype-nexus" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f deployment.yaml -refresh=true"
  }

    provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete -f deployment.yaml --ignore-not-found"
  }
}

resource "null_resource" "sonatype-nexus-service" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f service.yaml -refresh=true"
  }

  provisioner "local-exec" {
  when = destroy

  command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete -f service.yaml --ignore-not-found"
  }
}