resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              =  "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=x9D7XYbxSiMMVssulaXMBn4Q12u7SEHX1pqAkAToGJQ="
      "AzureServiceBus__EditEntityPath"          =  "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=1f8hCZFMPffFG7TUtv+JWMV94F+RgY1I3dgmlRh3xKc="
      "AzureServiceBus__DeleteEntityPath"        =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=dOB3YaQvCn6JTveBMen29pr9Ugk9o3h3X50tYGiI6aw="
      "AzureServiceBus__DeletedUsersEndPoint"    =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=JzwF1gV5j3J19tXwUFR94d9UFu3Nw+8R5nJu6w1XywI="
      "AzureServiceBus__DeletedUsersEntityPath"  =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeactivateEndpoint"      =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=8dLg1rD+Wef/yCBEv0iMMCnXdoL+Rbd1+rPfrbiW/A8="
      "AzureServiceBus__ActivateEndpoint"        =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=gVRdguOg57vdiENhEJtGtCmplyofHajJE4Le+wIxzMc="
      "TeamCreatedConnection"                    =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=9dul+PfKkRmhv4lCUArkN99RfmSYEON28DAL+tQ6Kcs=;"
      "AzureServiceBus__UpdatedUsersEndpoint"    =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=+Eroe177bx7QH4Rxa27w/4JcQz+V/MQoioODtdYYR3Q=;"
      "AzureServiceBus__UpdatedUsersEntityPath"  =  "sapience-admin-users-updated"
      "AzureServiceBus__TeamDeletedConnection"                    =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=EIlG8bZWeJ/ypzFmMJ+wPElD/iiLx5bJN6hfBqAmzYU=;"
      "AzureServiceBus__TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=OLmzMRHwkQuX0UkeiwTD3GkvOYp4VxlR3Oc47GQFw4g=;"

      #Admin_service_bus

      "AzureServiceBus__DepartmentUpdatedEntityPath" = "sapience-admin-departments-updated"
      "AzureServiceBus__DepartmentUpdatedConnection" = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=gA7au21i7pFQRZXWebxQh7NH8knG54Nuua71xQdubF8=;"
      "AzureServiceBus__DepartmentDeletedEntityPath" = "sapience-admin-departments-deleted"
      "AzureServiceBus__DepartmentDeletedConnection" = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=jdYwyKYVdjgB79tq7elB92E1Jxs5ERxZpUzx1gcTc68=;"
      "AzureServiceBus__ActivityUpdatedEntityPath"   = "sapience-admin-activity-updated"
      "AzureServiceBus__ActivityUpdatedConnection"   = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=1usxEmVxTblHS9HgBO+bw61olso9UNI6SJ25PoX0gHM=;"
      "AzureServiceBus__ActivityDeletedEntityPath"   = "sapience-admin-activity-deleted"
      "AzureServiceBus__ActivityDeletedConnection"   = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=O8P9TjtX7YTGfFGYUrl1i+la5NWuovgBeGgN9lWEzQo=;" 
  }
}
