resource "kubernetes_config_map" "integrations" {
  metadata {
    name      = "integrations"
    namespace = local.namespace
  }

  data = { 
      "AzureFuncSettings__BaseHost" = "https://azure-func-app-sapience-admin-integrations-api-lab-us-dev.azurewebsites.net"
   }
}