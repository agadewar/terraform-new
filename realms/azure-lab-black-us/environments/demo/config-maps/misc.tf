resource "kubernetes_config_map" "misc" {
  metadata {
    name      = "misc"
    namespace = local.namespace
  }

  data = {
      "ASPNETCORE_ENVIRONMENT"      =   "Development"
      "ENVIRONMENT_API_URL"         =   "https://api.demo.lab.us.azure.sapienceanalytics.com"
      "LocalSwagger"                =   "false"
      "API_URL"                     =   "http://sapience-app-alerts/alertrules/company/eval"
      "ENVIRONMENT_VUE_URL"         =   "https://app.dev.sapienceanalytics.com"
      "ENVIRONMENT_ADMIN_URL"       =   "https://manage.dev.sapienceanalytics.com"
      "ENVIRONMENT_VUE_HELP_URL"    =   "https://help.dev.lab.us.azure.sapienceanalytics.com"
  }
}
