resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT" = "Development"
      "ENVIRONMENT_API_URL" = "https://api.dev.lab.us.azure.sapienceanalytics.com"
      "LocalSwagger" = "false"
      "API_URL" = "http://sapience-app-alerts/alertrules/company/eval"
  }
}