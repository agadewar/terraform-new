resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"    =  false
      "AzureServiceBus__EntityPath"            = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"              = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=8BmR/2LJF/UUywDzgbShfobMWopEN1WVVjyT+RuBW5g="
      "AzureServiceBus__EditEntityPath"        = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"          = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=RTMP/wTWoL4TftZV8m9cHcwwT3yhGlt2auFw/vEoAVc="
      "AzureServiceBus__DeleteEntityPath"      = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"        = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=I0SPY/91uh/fwGAn8FI++mvKs+GNorXsFhhluhvRccg="
  }
}
