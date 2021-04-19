resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              =  "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=5qUDVqkfHhmGS+KYIAnuvYEMU3N+CrcxiUhfI8t9kT0="
      "AzureServiceBus__EditEntityPath"          =  "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=RTMP/wTWoL4TftZV8m9cHcwwT3yhGlt2auFw/vEoAVc="
      "AzureServiceBus__DeleteEntityPath"        =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=I0SPY/91uh/fwGAn8FI++mvKs+GNorXsFhhluhvRccg="
      "AzureServiceBus__DeletedUsersEndPoint"    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Jip9weAu9AbCQ2f0KsNeaSBlNWaSn+hCwyfKq7U+gFk="
      "AzureServiceBus__DeletedUsersEntityPath"  =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeactivateEndpoint"      =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=uNdXAU7jqTk+kUTR5JnWfHC8oIFYRqTFyidwh9rPM/8="
      "AzureServiceBus__ActivateEndpoint"        =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=PFoEnkNW5iK14pwWzJeZ8tmCFZjYZ2mQMstLhg/6oso="
      "AzureServiceBus__TeamCreatedConnection"   =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=e3X/d+veSSV1+9jQl2+UipmuKnelcLm+YeZy2QuHmz0=;"
      "TeamDeletedConnection"                    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=RWtYxox0WvAu6BAgiJKkMukaJsyam1T4jLhvEWaTA3I=;"
      "TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=8tN2Sd6QY74ftp7XnftyEnJVXr0MOlOrejFpV12ZUdo=;"
  }
}
