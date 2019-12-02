terraform {
  backend "azurerm" {
    key = "sapience-app-api.tfstate"
  }
}

provider "kubernetes" {
  version = "1.7.0"
  config_path = local.config_path
}

locals {
  namespace = var.environment

  config_path = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Sapience App API"
    )
  )}"
}

resource "kubernetes_secret" "sapience_app_api" {
  metadata {
    labels = {
      "sapienceanalytics.com/name" = "sapience-app-api"
    }

    name = "sapience-app-api"
    namespace = local.namespace
  }

  data = {
      Sisense__Secret = var.sisense_secret
      ConnectionStrings__Staging = var.connectionstring_staging
      ConnectionStrings__Mad = var.connectionstring_mad
  }
}
