resource "kubernetes_secret" "etl_staging_database" {
  metadata {
    name = "etl-staging-database"
    namespace = local.namespace
  }

  data = {
      secret =  var.etl_secret
      password = var.staging_password
  }
}