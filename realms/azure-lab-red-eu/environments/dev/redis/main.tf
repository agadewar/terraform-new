terraform {
  backend "azurerm" {
    key = "red/redis.tfstate"
  }

  required_providers {
    helm = "= 1.0.0"
  }
}

provider "helm" {
  kubernetes {
    config_path = local.config_path
  }

  # #TODO - may want to pull service account name from kubernetes_service_account.tiller.metadata.0.name
  # service_account = "tiller"
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
  namespace = var.environment
  repository = "https://github.com/helm/charts/find/master"
  chart     = "stable/redis"
  verify    = false

  set {
    name  = "usePassword"
    value = "true"
  }

  set {
    name  = "password"
    value = var.redis_password
  }

  set {
    name = "cluster.enabled"
    value = var.redis_cluster_enabled
  }

  set {
    name = "cluster.slaveCount"
    value = var.redis_cluster_slavecount
  }

  set {
    name = "sentinels.enabled"
    value = "true"
  }

  set {
    name = "master.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name = "master.resources.requests.cpu"
    value = "100m"
  }

  set {
    name = "slave.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name = "slave.resources.requests.cpu"
    value = "100m"
  }
}
