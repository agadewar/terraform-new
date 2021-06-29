terraform {
  backend "azurerm" {
    key = "functions.tfstate"
  }
}

provider "azurerm" {
  version         = "1.31.0"
  subscription_id = var.subscription_id
}

locals {
  common_tags = merge(
    var.realm_common_tags,
    var.environment_common_tags,
    {
      "Component" = "Functions"
    },
  )
}

# data "terraform_remote_state" "storage_account" {
#   backend = "azurerm"

#   config = {
#     access_key           = var.realm_backend_access_key
#     storage_account_name = var.realm_backend_storage_account_name
#     container_name       = var.realm_backend_container_name
#     key                  = "storage-account.tfstate"
#   }
# }

resource "azurerm_storage_account" "sapience_functions_admin_users" {
  name                     = "adminfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "northeurope"
  account_kind             = "Storage"
  account_tier             = "Standard"
  enable_https_traffic_only = false
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_plan_admin_users" {
  name                = "azure-functions-service-plan-admin-users-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_admin_users" {
  name                        = "azure-functions-app-sapience-user-provisioning-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_admin_users.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string   = azurerm_storage_account.sapience_functions_admin_users.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      #AzureWebJobsStorage                     =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      Connection                               =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=fjaP10G9ci2lROBXL5wapfrvG3tCTYtqE4Qt1VB+SM4=;"
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      Auth0__Connection                        =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId             =  "5BIiNYJDqLcNet95rtK5VaQh9IC9Jqa5"
      Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience             =  "https://sapience-lab-eu-dev.eu.auth0.com/api/v2/"
      Auth0__ManagementApiSecret               =  "bgcgF-i2vdtnq2Ut4HtbB_fXRgqgAOxWq6fpXXG1-ebVhTt_Jxvoh-hzETkHOemo"
      Sisense__BaseUrl                         =  "https://sapiencebi.dev.eu.azure.sapienceanalytics.com/"
      Sisense__UsersUri                        =  "api/v1/users/bulk"
      Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                             =  "Dev"
      Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNjBkOTY2Zjk0MGRjMTEwMDJjNDQ3ODRhIiwiYXBpU2VjcmV0IjoiYjM4M2VkOWEtMzNkYy02NDNhLTE1YmMtYTFjOTY4ODY3YmRiIiwiaWF0IjoxNjI0ODYwNTY5fQ.pF4PG1r-jRHvA3bSqa2bltmkqX-DFx1I3t6vppPnm0Y"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "15ae11d2-60f2-4890-a2e0-90b496fe2f11"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=15ae11d2-60f2-4890-a2e0-90b496fe2f11;IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/"
      ConnectionString                         =   "Data Source=sapience-lab-eu-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxdefFvWThiZG;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      EditConnection                           =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=/6yoEBHUmSPSKvH9UibZhqz0nlL8lBoXwGNHIqzMl5c=;"
      DeleteConnection                         =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=N7U9mVBlvjv4E4GhDyWkqDxxrXJhbCURFEW4QLIoo9k=;"
      Auth0__ManagementApiBaseUrl              =  "https://sapience-lab-eu-dev.eu.auth0.com"
      Canopy__Auth0Url                         =  "https://api.dev.lab.eu.azure.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                      =  "sapience:ashish.gadewar@sapienceanalytics.com:Ashish@123"
      Canopy__UserServiceUrl                   =  "https://api.dev.lab.eu.azure.sapienceanalytics.com/user/v1/users/"
      "Sisense:EditUserUri"                    =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      "Sisense:GetUserUri"                     =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      "Sisense__DeleteUserUri"                 =  "api/v1/users/"
      "Sisense__OperatingSystem"               =  "linux"
      "Sisense__Server"                        =  "localhost"
      "TeamCreatedConnection"                   = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=IFLPqXRJChHCmkVVKasigU+FS6QC9vu6edby47ALXAQ=;"
      "TeamDeletedConnection"                   = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=dlodv1vkFj4wMYq+DLMjwu5klqt8MH4049VsLPVzPN4=;"
      "TeamUpdatedConnection"                   = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=0oMgAeAmbCu/NlMj9Af8IQQrSydZgnPWIc8by2A+FJE=;"
      "UserActivatedConnection"                 = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=QET/mcxnwelKmYIeWB/kR0QcnEnJ/23QUoIqrnEYPY8=;"
      "UserDeactivatedConnection"               = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=W8XpOQkRvQbyxfm6A+LH5yz1hu4uF6zlG5QDoI+jkao=;"


  }
}

resource "azurerm_function_app" "bulk_upload" {
  name                      = "azure-admin-bulk-upload-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_bulk_upload_plan_admin_users.id
  storage_connection_string = azurerm_storage_account.sapience_bulk_upload_admin_users.primary_connection_string
  version                   = "3.1"
  app_settings              = {
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     =  true
    WEBSITE_RUN_FROM_PACKAGE            =  "1"
  }
}

resource "azurerm_storage_account" "sapience_bulk_upload_admin_users" {
  name                     = "adminfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_kind             = "Storage"
  enable_https_traffic_only = false
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_bulk_upload_plan_admin_users" {
  name                = "azure-bulk-upload-service-plan-admin-users-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_storage_account" "sapience_functions_tenant_teardown" {
  name                     = "sapteardownfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_kind             = "Storage"
  enable_https_traffic_only = false
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_plan_sapience_tenant_teardown" {
  name                = "azure-fun-service-plan-sap-tenant-teardown-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_sapience_tenant_teardown" {
  name                        = "azure-functions-app-sapience-tenant-teardown-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_sapience_tenant_teardown.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string   = azurerm_storage_account.sapience_functions_tenant_teardown.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      #AzureWebJobsStorage                     =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      #Connection                               =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      Auth0__Connection                        =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId             =  "5BIiNYJDqLcNet95rtK5VaQh9IC9Jqa5"
      Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience             =  "https://sapience-lab-eu-dev.eu.auth0.com/api/v2/"
      Auth0__ManagementApiSecret               =  "bgcgF-i2vdtnq2Ut4HtbB_fXRgqgAOxWq6fpXXG1-ebVhTt_Jxvoh-hzETkHOemo"
      Sisense__BaseUrl                         =  "https://sapiencebi.dev.eu.azure.sapienceanalytics.com/"
      Sisense__UsersUri                        =  "api/v1/users/bulk"
      Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                             =  "Dev"
      Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3MWMzZTRmNTg5M2YwMDJjOGM5MmIzIiwiYXBpU2VjcmV0IjoiMTY5N2E1ODgtZThiYS1iZDc5LTM1NTUtN2VlNGQ1ODRhMzYxIiwiaWF0IjoxNjAzNjA3ODAxfQ.ZG9i_H00xo7Kd9wGHcMaF_WyyDe7_LFCenp8iSa843U"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "15ae11d2-60f2-4890-a2e0-90b496fe2f11"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=15ae11d2-60f2-4890-a2e0-90b496fe2f11;IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/"
      ConnectionString                         =  "Data Source=sapience-lab-eu-dev.database.windows.net;Database=Admin;User=appsvc_tenant_user;Password=vqFKG9VIjnVpOI;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      EditConnection                           =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=/6yoEBHUmSPSKvH9UibZhqz0nlL8lBoXwGNHIqzMl5c=;"
      DeleteConnection                         =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=N7U9mVBlvjv4E4GhDyWkqDxxrXJhbCURFEW4QLIoo9k=;"
      Auth0__ManagementApiBaseUrl              =  "https://sapience-lab-eu-dev.eu.auth0.com"
      Canopy__Auth0Url                         =  "https://api.dev.lab.eu.azure.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                      =  "Sapience:canopy_service_account:xhPNAhEtyGpTYYU58tlH#h"
      Canopy__UserServiceUrl                   =  "https://api.dev.lab.eu.azure.sapienceanalytics.com/user/v1/users/"
      "Sisense:EditUserUri"                    =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      "Sisense:GetUserUri"                     =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      "Sisense__DeleteUserUri"                 =  "api/v1/users/"
      "Sisense__OperatingSystem"               =  "linux"
      "Sisense__Server"                        =  "localhost"
      "TeamCreatedConnection"                  = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=IFLPqXRJChHCmkVVKasigU+FS6QC9vu6edby47ALXAQ=;"
      "TeamDeletedConnection"                  = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=dlodv1vkFj4wMYq+DLMjwu5klqt8MH4049VsLPVzPN4=;"
      "TeamUpdatedConnection"                  = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=0oMgAeAmbCu/NlMj9Af8IQQrSydZgnPWIc8by2A+FJE=;"
      "UserActivatedConnection"                = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=QET/mcxnwelKmYIeWB/kR0QcnEnJ/23QUoIqrnEYPY8=;"
      "UserDeactivatedConnection"              = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=W8XpOQkRvQbyxfm6A+LH5yz1hu4uF6zlG5QDoI+jkao=;"

  }
}

resource "azurerm_app_service_plan" "service_plan_admin_support_api" {
  name                = "azure-fun-service-plan-sap-admin-support-api-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_sapience_admin_support_api" {
  name                        = "azure-functions-app-sapience-admin-support-api-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_admin_support_api.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string   = azurerm_storage_account.sapience_functions_admin_support_api.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      #AzureWebJobsStorage                      =  "UseDevelopmentStorage=true"
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "15ae11d2-60f2-4890-a2e0-90b496fe2f11"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=15ae11d2-60f2-4890-a2e0-90b496fe2f11;IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/"
      ConnectionString                         =   "Data Source=sapience-lab-eu-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxdefFvWThiZG;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          = true
      WEBSITE_RUN_FROM_PACKAGE                 = 1
  }
}

resource "azurerm_storage_account" "sapience_functions_admin_support_api" {
  name                     = "sapadminsupapifn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_storage_account" "sapience_functions_admin_int_api" {
  name                     = "sapadminintapifn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_kind             = "Storage"
  enable_https_traffic_only = false
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_plan_sapience_admin_integrations_api" {
  name                = "azure-fun-service-plan-sap-admin_int_api-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_sapience_admin_integrations_api" {
  name                        = "azure-func-app-sapience-admin-integrations-api-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_sapience_admin_integrations_api.id
  storage_connection_string   = azurerm_storage_account.sapience_functions_admin_int_api.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "15ae11d2-60f2-4890-a2e0-90b496fe2f11"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=15ae11d2-60f2-4890-a2e0-90b496fe2f11;IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      "AzureServiceBus:Endpoint"                 =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=uAyfQQRRJiyGDDw16SEpNideMyE9r5zGakbOrbPf/Is=;"
      "AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      "AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=wi0T3iamELCeA9ekczpALDMKRBQUmp1AGHeC59w8Fso=;"
      "AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      "IdentityProvider:Issuer"                  =  "https://sapience-lab-eu-dev.eu.auth0.com/"
      "IdentityProvider:Audience"                =  "https://api.sapienceanalytics.com"
      "Auth0:Authority"                          =  "https://sapience-lab-eu-dev.eu.auth0.com/"
      "Auth0:Audience"                           =  "https://api.sapienceanalytics.com"
      "Auth0:ClientId"                           =  "5BIiNYJDqLcNet95rtK5VaQh9IC9Jqa5"
      "Auth0:Connection"                         =  "Username-Password-Authentication"
      "Auth0:PingUri"                            =  "https://sapience-lab-eu-dev.eu.auth0.com/test"
      Sisense__BaseUrl                           =  "https://sapiencebi.dev.eu.azure.sapienceanalytics.com/"
      Sisense__Secret                            =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNjBkOTY2Zjk0MGRjMTEwMDJjNDQ3ODRhIiwiYXBpU2VjcmV0IjoiYjM4M2VkOWEtMzNkYy02NDNhLTE1YmMtYTFjOTY4ODY3YmRiIiwiaWF0IjoxNjI0ODYwNTY5fQ.pF4PG1r-jRHvA3bSqa2bltmkqX-DFx1I3t6vppPnm0Y"
      "ConnectionStrings:Admin"                  =  "Data Source=sapience-lab-eu-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxdefFvWThiZG"
      "ConnectionStrings:Staging"                =  "Data Source=sapience-lab-eu-dev.database.windows.net;Database=Staging;User=appsvc_api_user;Password=3HvaNxdefFvWThiZG;"
      "UploadBlob:Container"                     = "sapience-upload"
      "UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=saplabeubudev;AccountKey=lK43CdZRdAWOD7QpP39IdFUXqNJnZuEgtfFYSIWqo5afa/qum0vXERZu8VMAhxC+UXdpm/0G/6P+2G8HrsGHyw==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-lab-eu-dev:tlmu2HswmeYErnohmiQJrJilHz0Aqp9yvul7NwIYaALmzRaQO4NYh7fnHdJqekDfNX7ICZJq9JMDIZzx0ZHgwQ==@sapience-bulk-upload-mongodb-lab-eu-dev.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      "BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
      "Integration:ConnString"                   =  "AccountEndpoint=mongodb+srv://sapience-integration-mongodb-lab-eu-dev:uF1df62bQ2sLmsDNqQTOWpAEv6E2zB65fmEP7RojJSZfqpDGqdBZHuj7peVpx9syfszTY4n4StzxflyWmHXe0Q==@sapience-integration-mongodb-lab-eu-dev.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-lab-eu-dev@;AccountKey=uF1df62bQ2sLmsDNqQTOWpAEv6E2zB65fmEP7RojJSZfqpDGqdBZHuj7peVpx9syfszTY4n4StzxflyWmHXe0Q=="
      "Integration:DatabaseName"                 =  "Test"
      "Integration:Collections:IntegrationEvents" =  "Integration_Events"
  }
}

resource "azurerm_storage_account" "sapience_functions_notifications" {
  name                     = "sapiencenotifn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "northeurope"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_plan_notifications" {
  name                = "azure-function-service-plan-sap-notifications-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_sapience_notifications" {
  name                        = "azure-functions-app-sapience-notifications-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_notifications.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string   = azurerm_storage_account.sapience_functions_notifications.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=j/hMutLqKydATpYMEpfYUqv9mAQzHg1RDqeaJD5PdHA=;"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=sTU9o7/bjnerWk55IW3dUtZc5UXOD82T5kwX/swK5LE=;"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=rcoAE+cFUPjMGs56EQ9JwXEr5hr0qHBLTU9azc+7Q/0=;"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=XrP6ncnEQm9eJmJkm8QqdQRIkv9xZgqIyjb85GeXHlQ=;"
  }
}