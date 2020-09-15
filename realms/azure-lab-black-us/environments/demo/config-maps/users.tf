resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"    =  false
      "AzureServiceBus__EntityPath"            = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"              = ""
  }
}
