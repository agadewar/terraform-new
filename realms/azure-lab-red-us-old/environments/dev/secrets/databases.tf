resource "kubernetes_secret" "databases" {
  metadata {
    name = "databases"
    namespace = local.namespace
  }

  data = {
      admin_database = var.connectionstring_admin
      mad_database = var.connectionstring_mad
      staging_database = var.connectionstring_staging
  }
}