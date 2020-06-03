resource "kubernetes_secret" "databases" {
  metadata {
    name = "databases"
    namespace = local.namespace
  }

  data = {
      admin = var.connectionstring_admin
      mad = var.connectionstring_mad
      staging = var.connectionstring_staging
      mongodb = var.connectionstring_mongo
      edw = var.connectionstring_edw
      machine_learning_service_account_password = var.machine_learning_service_account_password
  }
}
