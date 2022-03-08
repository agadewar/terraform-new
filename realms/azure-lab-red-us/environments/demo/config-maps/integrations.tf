resource "kubernetes_config_map" "integrations" {
  metadata {
    name      = "integrations"
    namespace = local.namespace
  }

  data = { 
      "AzureFuncSettings__BaseHost" = "https://azure-admin-bulk-upload-lab-us-demo.azurewebsites.net"
   }
}