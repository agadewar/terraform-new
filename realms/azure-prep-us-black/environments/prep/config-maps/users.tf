resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              =  "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=a9O/KvBp6ZQuEKdNcP/+lW5AKzCgHjJZOwlDBcB/h1A="
      "AzureServiceBus__EditEntityPath"          =  "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=9Q+CcCj96ZO6WfQGubUshe3MxfkCxRfTdmzdFiFa/6s=;"
      "AzureServiceBus__DeleteEntityPath"        =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=JyIiFrOIMqOtzq/wYmRv/o2rLcUaotplo+QeRM4iu0o=;"
      "AzureServiceBus__DeletedUsersEndPoint"    =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=JyIiFrOIMqOtzq/wYmRv/o2rLcUaotplo+QeRM4iu0o=;"
      "AzureServiceBus__DeletedUsersEntityPath"  =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeactivateEndpoint"      =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=A6Dn25z3FeZRZryLaWRUmwRUwhFUhqj4uUhGj6STgAI=;"
      "AzureServiceBus__ActivateEndpoint"        =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=jowYceeQpDZZupBD6Q4gmbGX9vx7mTnJCx+/s/B3jQs=;"
      "AzureServiceBus__UpdatedUsersEndpoint"    =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=dLjObUX1X+s6F5svzcI3lsmHDCjIFbp3xNE3D3lQ7lk=;"
      "AzureServiceBus__UpdatedUsersEntityPath"  =  "sapience-admin-users-updated"
      "AzureServiceBus__TeamCreatedConnection"   =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=4plArHnvW9+aWwFr3wipi/jtdkuJFZgoGSBonB3kMa4=;"
      "AzureServiceBus__TeamDeletedConnection"   =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=zM9GQopfWaLsWMjG3diWmW74pAQsmKstxbVP0DsDjus=;"
      "AzureServiceBus__TeamUpdatedConnection"   =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=XNQlL5BmqV/YZt2IJ5j+WXwCs8uEecLeffaZJwrMTjY=;"
      "TeamCreatedConnection"                    =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=4plArHnvW9+aWwFr3wipi/jtdkuJFZgoGSBonB3kMa4=;"
      "TeamDeletedConnection"                    =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=zM9GQopfWaLsWMjG3diWmW74pAQsmKstxbVP0DsDjus=;"
      "TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=XNQlL5BmqV/YZt2IJ5j+WXwCs8uEecLeffaZJwrMTjY=;"

      #Admin_service_bus

      "AzureServiceBus__DepartmentUpdatedEntityPath" = "sapience-admin-departments-updated"
      "AzureServiceBus__DepartmentUpdatedConnection" = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=aKk+fw/hPBmsRKP+Upf8lFlYEeHR8sc8VcIgEurme3I=;"
      "AzureServiceBus__DepartmentDeletedEntityPath" = "sapience-admin-departments-deleted"
      "AzureServiceBus__DepartmentDeletedConnection" = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=P8SO3miLFd4q6FyEuCkWkiaOx1MguMSp7axXf3H6qOw=;"
      "AzureServiceBus__ActivityUpdatedEntityPath"   = "sapience-admin-activity-updated"
      "AzureServiceBus__ActivityUpdatedConnection"   = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=su2dd4DzcmZ75Wa+woJe3sl1GHDFqP9d8FvthOFxqPw=;"
      "AzureServiceBus__ActivityDeletedEntityPath"   = "sapience-admin-activity-deleted"
      "AzureServiceBus__ActivityDeletedConnection"   = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Jww+RloNacwYvh30ahoK8xQT0x4wTJuF4ByRWD00dSM=;" 
  }
}
