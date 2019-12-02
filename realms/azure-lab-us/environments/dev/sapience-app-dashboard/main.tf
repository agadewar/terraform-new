terraform {
  backend "azurerm" {
    key = "sapience-app-dashboard.tfstate"
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
      "Component", "Sapience App Dashboard"
    )
  )}"
}

resource "kubernetes_secret" "sapience_app_dashboard" {
  metadata {
    labels = {
      "sapienceanalytics.com/name" = "sapience-app-dashboard"
    }

    name = "sapience-app-dashboard"
    namespace = local.namespace
  }

  data = {
      CosmosDb__Key = var.cosmosdb_key_dashboard
      ApplicationInsights__InstrumentationKey = var.appinsights_key
  }
}