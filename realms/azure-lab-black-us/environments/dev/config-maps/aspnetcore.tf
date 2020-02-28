resource "kubernetes_config_map" "aspnetcore" {
  metadata {
    name      = "aspnetcore"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT" = "Development"
  }
}