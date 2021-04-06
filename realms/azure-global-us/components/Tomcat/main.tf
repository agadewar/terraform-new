terraform {
  backend "azurerm" {
    key = "tomcat.tfstate"
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
  namespace   = "tomcat"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "tomcat"
    },
  )
}

# resource "helm_release" "apache-tomcat" {
#   name      = "apache-tomcat"
#   namespace = "tomcat"
#   chart     = "stable/apache-tomcat"
# }

resource "null_resource" "apache-tomcat" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f deployment.yaml"
  }

    provisioner "local-exec" {
    when = destroy

    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete -f deployment.yaml --ignore-not-found"
  }
}

resource "null_resource" "apache-tomcat-service" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} apply -f service.yaml"
  }

  provisioner "local-exec" {
  when = destroy

  command = "kubectl --kubeconfig=${local.config_path} -n ${local.namespace} delete -f service.yaml --ignore-not-found"
  }
}