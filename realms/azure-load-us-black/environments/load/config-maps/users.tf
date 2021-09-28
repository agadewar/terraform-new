resource "kubernetes_config_map" "users" {
  metadata {
    name      = "users"
    namespace = local.namespace
  }

  data = {
      "AzureServiceBus__UseAzureServiceBus"      =  true
      "AzureServiceBus__EntityPath"              =  "sapience-admin-users-created"
      "AzureServiceBus__Endpoint"                =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=KzggZ7ksDIiPqA2tBPC4dKhVEyx/tFjbwNOgfScVzzU="
      "AzureServiceBus__EditEntityPath"          =  "sapience-admin-users-updated"
      "AzureServiceBus__EditEndpoint"            =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=uMRxh0FkdvxoMc0uPguwrBoJHNh/1wiRZLOPcbu+MfM="
      "AzureServiceBus__DeleteEntityPath"        =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeleteEndpoint"          =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=PeAGpUP3G2TrPI/7s/V2KePGQbmalWfFeDtirS1nKbE="
      "AzureServiceBus__DeletedUsersEndPoint"    =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=e7RAJ4FN7d0fLTr/lwkORZHEtIfOA6/zy+IEQQGXBNk="
      "AzureServiceBus__DeletedUsersEntityPath"  =  "sapience-admin-users-deleted"
      "AzureServiceBus__DeactivateEndpoint"      =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=WRq/xnJmRQJpqSpGoYBAI9w4WR2+AKNC2pYwXuMZPWM="
      "AzureServiceBus__ActivateEndpoint"        =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Qeymv5tI/xs6h+VXzMFQRcID3pJzLZfmy0FMiseBtY0="
      "AzureServiceBus__UpdatedUsersEndpoint"    =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=bJ+zPQg0nvacGg1+AZ6uCVlMNyG98DZji/MC3UlnG0w=;"
      "AzureServiceBus__UpdatedUsersEntityPath"  =  "sapience-admin-users-updated"
      "TeamCreatedConnection"                    =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=dbWfJKUm1hSJOOs3AwSXu84FBVx5TV+GNKSqqHyoEJc=;"
      "TeamDeletedConnection"                    =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=eeYaDbe93jzQXpYqxi0Qkt0EX0q8b58biD3MNkeepAk=;"
      "TeamUpdatedConnection"                    =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=nRssOd909AmvAVCd7/ycLmZQeViK4a+RSQ2cbpPMA1Q=;"

      #Admin_service_bus

      "AzureServiceBus__DepartmentUpdatedEntityPath" = "sapience-admin-departments-updated"
      "AzureServiceBus__DepartmentUpdatedConnection" = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=QmbcZqP7JF8PuuV53p7YF2MYU3QOx+ExHBxKpNC4nrc=;"
      "AzureServiceBus__DepartmentDeletedEntityPath" = "sapience-admin-departments-deleted"
      "AzureServiceBus__DepartmentDeletedConnection" = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=zxNGv0GIm5xuv60JB6BVlogV9dyrpW30vQGh8AvUPUU=;"
      "AzureServiceBus__ActivityUpdatedEntityPath"   = "sapience-admin-activity-updated"
      "AzureServiceBus__ActivityUpdatedConnection"   = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=qzuc67RK4R9MI2JQT8EbXrl1aXecNtYUbJKAvsPCrB4=;"
      "AzureServiceBus__ActivityDeletedEntityPath"   = "sapience-admin-activity-deleted"
      "AzureServiceBus__ActivityDeletedConnection"   = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Y0miz8K6up5Z06bAUU1N4FCvySdgZfPCTEc8LmgUEXk=;"
  }
}
