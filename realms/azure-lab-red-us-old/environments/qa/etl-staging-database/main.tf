terraform {
  backend "azurerm" {
    key = "red/etl-staging-database.tfstate"
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
      "Component", "ETL Staging Database"
    )
  )}"
}

resource "kubernetes_secret" "etl_staging_database" {
  metadata {
    labels = {
      "sapienceanalytics.com/name" = "etl-staging-database"
    }

    name = "etl-staging-database"
    namespace = local.namespace
  }

  data = {
      STAGING_DATABASE_PASSWORD = var.sql_server_appsvc_etl_user_password
      KAFKA_CLUSTER_API_SECRET = var.kafka_password
  }
}
