resource "kubernetes_secret" "databases" {
  metadata {
    name = "databases"
    namespace = local.namespace
  }

  data = {
      admin = var.connectionstring_admin
      mad = var.connectionstring_mad
      staging = var.connectionstring_staging
      edw  =  var.connectionstring_edw
      mongodb = var.connectionstring_mongo
  }
}
