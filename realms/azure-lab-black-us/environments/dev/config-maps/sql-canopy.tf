resource "kubernetes_config_map" "sql_canopy" {
  metadata {
    name      = "sql-canopy"
    namespace = local.namespace
  }

  data = {
    "hostname" = var.sql_canopy_hostname
  }
}