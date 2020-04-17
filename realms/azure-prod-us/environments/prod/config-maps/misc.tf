resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT" = "Production"
      "ENVIRONMENT_API_URL" = "https://api.prod.prod.us.azure.sapienceanalytics.com"
      "LocalSwagger" = "false"
  }
}