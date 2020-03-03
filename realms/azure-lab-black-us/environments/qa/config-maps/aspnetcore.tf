resource "kubernetes_config_map" "aspnetcore" {
  metadata {
    name      = "aspnetcore"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT" = "Development"
      "ENVIRONMENT_API_URL" = "https://api.qa.lab.us.azure.sapienceanalytics.com"
      "LocalSwagger" = "false"
  }
}