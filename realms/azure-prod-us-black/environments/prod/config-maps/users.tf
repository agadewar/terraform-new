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
      "AzureServiceBus__UpdatedUsersEndpoint"    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=kLg6nmBU3hX+rhaIA8iItDZLIgoHSxu56e4tKIvbjBQ=;"
      "AzureServiceBus__UpdatedUsersEntityPath"  =  "sapience-admin-users-updated"
      "TeamCreatedConnection"                    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=e3X/d+veSSV1+9jQl2+UipmuKnelcLm+YeZy2QuHmz0=;"
      "TeamDeletedConnection"                    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=RWtYxox0WvAu6BAgiJKkMukaJsyam1T4jLhvEWaTA3I=;"
      "TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=8tN2Sd6QY74ftp7XnftyEnJVXr0MOlOrejFpV12ZUdo=;"

      #Admin_service_bus

      "AzureServiceBus__DepartmentUpdatedEntityPath" = "sapience-admin-departments-updated"
      "AzureServiceBus__DepartmentUpdatedConnection" = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=iAq0gX1umWvQTQv4gbVewcUc7oQgLy7ZP4XRYKC3oMc=;"
      "AzureServiceBus__DepartmentDeletedEntityPath" = "sapience-admin-departments-deleted"
      "AzureServiceBus__DepartmentDeletedConnection" = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=UBI7L74lpgmUu7dhBttFzFRww9rRMv1VIR0uVC7Ctqw=;"
      "AzureServiceBus__ActivityUpdatedEntityPath"   = "sapience-admin-activity-updated"
      "AzureServiceBus__ActivityUpdatedConnection"   = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=enH/BBHSMGl1lHTe0C750qRamabolvA4STCT0MGig4E=;"
      "AzureServiceBus__ActivityDeletedEntityPath"   = "sapience-admin-activity-deleted"
      "AzureServiceBus__ActivityDeletedConnection"   = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=sJTxtxJQPk3pTbAXNkbrYVK3DmPtUHwgWaVp62Dr0X4=;" 
  }
}
