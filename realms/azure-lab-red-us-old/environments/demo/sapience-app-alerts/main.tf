terraform {
  backend "azurerm" {
    key = "red/sapience-app-alerts.tfstate"
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

data "terraform_remote_state" "cosmos_db" {
  backend = "azurerm"
  config = {
    access_key           = var.env_backend_access_key
    storage_account_name = var.env_backend_storage_account_name
	  container_name       = var.env_backend_container_name
    key                  = "database.tfstate"
  }
}

locals {
  namespace = var.environment

  config_path = "../../../components/kubernetes/.local/kubeconfig"

  common_tags = "${merge(
    var.realm_common_tags,
    var.environment_common_tags,
    map(
      "Component", "Sapience App Alerts"
    )
  )}"
}

resource "kubernetes_secret" "sapience_app_alerts" {
  metadata {
    labels = {
      "sapienceanalytics.com/name" = "sapience-app-alerts"
    }

    name = "sapience-app-alerts"
    namespace = local.namespace
  }

  data = {
      NotificationsDb__Key = data.terraform_remote_state.cosmos_db.outputs.lab_us_demo_alerts_cosmos_password
      ApplicationInsights__InstrumentationKey = data.terraform_remote_state.app_insights.outputs.instrumentation_key
  }
}