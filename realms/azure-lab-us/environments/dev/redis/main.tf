terraform {
  backend "azurerm" {
    key = "redis.tfstate"
  }
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  service_account = "tiller"
}

locals {
  config_path = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = merge(
    var.realm_common_tags,
    {
      "Component" = "Redis"
    },
  )
}

resource "helm_release" "redis" {
  name      = "redis"
  namespace = "redis"
  chart     = "stable/redis"

  set {
  name  = "usePassword"
  value = "true"
  }

  set {
  name  = "password"
  value = var.redis_password
  }
}
