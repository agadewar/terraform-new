terraform {
  backend "azurerm" {
    key = "black/sapience-app-api.tfstate"
  }
}

provider "kubernetes" {
  version = "1.7.0"
  config_path = local.config_path
}

data "terraform_remote_state" "app_insights" {
  backend = "azurerm"
  config = {
    access_key           = var.realm_backend_access_key
    storage_account_name = var.realm_backend_storage_account_name
	  container_name       = var.realm_backend_container_name
    key                  = "app-insights.tfstate"
  }
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
      ApplicationInsights__InstrumentationKey = data.terraform_remote_state.app_insights.outputs.instrumentation_key
      Sisense__Secret = var.sisense_secret
      ConnectionStrings__Staging = var.connectionstring_staging
      ConnectionStrings__Mad = var.connectionstring_mad
  }
}
