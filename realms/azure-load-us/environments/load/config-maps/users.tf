resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"    =  false
      "AzureServiceBus__EntityPath"            = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"              = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey="
      "AzureServiceBus__EditEntityPath"        = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"          = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey="
      "AzureServiceBus__DeleteEntityPath"      = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"        = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey="
  }
}
