terraform {
  backend "azurerm" {
    key = "red/sapience-app-dashboard.tfstate"
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
      "Component", "POST API Notifications"
    )
  )}"
}

resource "kubernetes_secret" "post_api_notifications" {
  metadata {
    labels = {
      "sapienceanalytics.com/name" = "post-api-notifications"
    }

    name = "post-api-notifications"
    namespace = local.namespace
  }

  data = {
      notifications_config = "[ { "username": "Janice.Bell@sapience.net", "password": "Janice123", "client_id": "gEurUe965S21CvJyQtArQ3z8TahgC20K"} ]"
  }
}