resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              = "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=5qUDVqkfHhmGS+KYIAnuvYEMU3N+CrcxiUhfI8t9kT0="
      "AzureServiceBus__EditEntityPath"          = "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=RTMP/wTWoL4TftZV8m9cHcwwT3yhGlt2auFw/vEoAVc="
      "AzureServiceBus__DeleteEntityPath"        = "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=I0SPY/91uh/fwGAn8FI++mvKs+GNorXsFhhluhvRccg="
      "AzureServiceBus__DeletedUsersEndPoint"    = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Jip9weAu9AbCQ2f0KsNeaSBlNWaSn+hCwyfKq7U+gFk="
      "AzureServiceBus__DeletedUsersEntityPath"  = "sapience-admin-users-deleted"
  }
}
