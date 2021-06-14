resource "kubernetes_secret" "databases" {
  metadata {
    name = "databases"
    namespace = local.namespace
  }

  data = {
      admin        = var.connectionstring_admin
      adminimport  = var.connectionstring_adminimport
      mad          = var.connectionstring_mad
      staging      = var.connectionstring_staging
      mongodb      = var.connectionstring_mongo
      edw          = var.connectionstring_edw
      dashboarddb   = var.connectionstring_dashboard_mongodb
      machine_learning_service_account_password = var.machine_learning_service_account_password
      MongoDBConnectorSettings__Password        = var.Mongodb_integration_password
  }
}
