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

resource "azurerm_storage_account" "sapience_functions_admin_users" {
  name                     = "adminfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
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
  name                      = "azure-functions-app-sapience-user-provisioning-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_plan_admin_users.id
  #app_settings              = var.function_app_admin_users  
  storage_connection_string = azurerm_storage_account.sapience_functions_admin_users.primary_connection_string
  version                   = "3.1"

      app_settings                            = {
      APPINSIGHTS_INSTRUMENTATIONKEY         =  "288fac0d-84e8-400a-b23e-f3f3a6103cac"
      APPLICATIONINSIGHTS_CONNECTION_STRING  =  "InstrumentationKey=288fac0d-84e8-400a-b23e-f3f3a6103cac;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      Connection                              =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=MZ4OW/3x1wWKm6/Cr+7XPCxyo/sfQlpyqydutF6XHY8="
      ConnectionString                        =  "Data Source=sapience-load-us-load.database.windows.net;Database=Admin;User=appsvc_api_user;Password=Khm8f426GxXf3x;"  
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "7TQZYoa2oy4HfN4HWHVPu1yAfmxhJSaz"
      Auth0__ManagementApiIdentifier          =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =  "https://sapience-load-us-load.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =  "https://sapience-load-us-load.auth0.com"
      Auth0__ManagementApiSecret              =  "jq42NLq1coMFF9wUAROCSc3hFdVt-MGv2gIbZBQvfaGukIdKodWXQ3dEQSRnLDGK"
      Sisense__BaseUrl                        =  "https://sisense-linux.load.sapienceanalytics.com/"
      Sisense__UsersUri                       =  "api/v1/users/bulk"
      Sisense__DefaultGroupUri                =  "api/v1/groups?name="
      Sisense__DataSecurityUri                =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =  "Load"
      Sisense__Server                         = "localhost"
      Sisense__Secret                         =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiYTBjNjExOTI4YWExYjY4Zjg0MmM0IiwiYXBpU2VjcmV0IjoiN2E5MzgyMWUtOTQyMy1mMjhkLWU3YmQtMGU5ZjY3NTIxOTdkIiwiaWF0IjoxNjExODk4NDUyfQ.3jBcZrMEsiybTX8qkdZtObKnJITRZQ0kPrOHq2vWfmk"
      Canopy__Auth0Url                        =  "https://api.load.sapienceanalytics.com/auth0/v1/integrations/auth0"
      #Canopy__Credentials                     =  "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =  "https://api.load.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=PeAGpUP3G2TrPI/7s/V2KePGQbmalWfFeDtirS1nKbE=;"
      EditConnection                          =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=uMRxh0FkdvxoMc0uPguwrBoJHNh/1wiRZLOPcbu+MfM=;"
      "Sisense:EditUserUri"                   =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"           =  "api/roles/contributor"
      "Sisense:GetUserUri"                    =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"             =  "api/roles/consumer" 
      Sisense__DeleteUserUri                  =  "api/v1/users/"
      Sisense__EditUserUri                    =  "api/v1/users/"
      Sisense__GetUserUri                     =  "api/v1/users?email="
      WEBSITE_ENABLE_SYNC_UPDATE_SITE         =  true 
      WEBSITE_RUN_FROM_PACKAGE                =  "1"
      "TeamCreatedConnection"                 = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=lONjMppRhLEkoN7OqdbpSU+e8Uqn7Ty27SHSJTnMujE=;"
      "TeamDeletedConnection"                 = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=yHCQukgieEHo4A8KP/aC23TLy9bRz00khUT6Iu6xrhQ=;"
      "TeamUpdatedConnection"                 = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=oC2aHrP96K3zrcrlHiV4DEniZ4xQRgLur0puMjQLV94=;"
      "UserActivatedConnection"               = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=MP2r4Jn5Asrf+JOqR8yTffxmBpM0jlr4H+85PIdcRGw=;"
      "UserDeactivatedConnection"             = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=GCI8zlrbthJkB+0t135zEnse4B9rPRT0GDmKHcjuwH4=;"

  }
}

resource "azurerm_storage_account" "sapience_functions_tenant_teardown" {
  name                     = "sapteardownfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
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

      app_settings                            = {
      APPINSIGHTS_INSTRUMENTATIONKEY         =  "288fac0d-84e8-400a-b23e-f3f3a6103cac"
      APPLICATIONINSIGHTS_CONNECTION_STRING  =  "InstrumentationKey=288fac0d-84e8-400a-b23e-f3f3a6103cac;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      Connection                              =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=MZ4OW/3x1wWKm6/Cr+7XPCxyo/sfQlpyqydutF6XHY8="
      ConnectionString                        =  "Data Source=sapience-load-us-load.database.windows.net;Database=Admin;User=appsvc_api_user;Password=Khm8f426GxXf3x;"  
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "EZP7r1fYqByogSKZ9LXveLh9KCHCHB4b"
      Auth0__ManagementApiIdentifier          =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =  "https://sapience-load-us-load.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =  "https://sapience-load-us-load.auth0.com"
      Auth0__ManagementApiSecret              =  "T4t4CxaW3lIqGXUkP8yZvmQdUXKu4hVJYXuewDHBIt-eHaUPog1lmW-7cFsJ-Ya5"
      Sisense__BaseUrl                        =  "https://sisense.load.load.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =  "api/users?email="
      Sisense__DefaultGroupUri                =  "api/v1/groups?name="
      Sisense__DataSecurityUri                =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =  "Load"
      Sisense__Secret                         =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiYTBjNjExOTI4YWExYjY4Zjg0MmM0IiwiYXBpU2VjcmV0IjoiN2E5MzgyMWUtOTQyMy1mMjhkLWU3YmQtMGU5ZjY3NTIxOTdkIiwiaWF0IjoxNjAxMzExNTMyfQ.w2Mgj6ELPUwo5tQat7U-HafWqY11vquC2rE24HdBFVQ"
      Canopy__Auth0Url                        =  "https://api.load.sapienceanalytics.com/auth0/v1/integrations/auth0"
      #Canopy__Credentials                     =  "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =  "https://api.load.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=PeAGpUP3G2TrPI/7s/V2KePGQbmalWfFeDtirS1nKbE=;"
      EditConnection                          =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=uMRxh0FkdvxoMc0uPguwrBoJHNh/1wiRZLOPcbu+MfM=;"
      "Sisense:EditUserUri"                   =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"           =  "api/roles/contributor"
      "Sisense:GetUserUri"                    =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"             =  "api/roles/consumer" 
      Sisense__DeleteUserUri                  =  "api/v1/users/"
      Sisense__EditUserUri                    =  "api/v1/users/"
      Sisense__GetUserUri                     =  "api/v1/users?email="
      WEBSITE_ENABLE_SYNC_UPDATE_SITE         =  true 
      WEBSITE_RUN_FROM_PACKAGE                =  "1" 

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
      #AzureWebJobsStorage                     =  "UseDevelopmentStorage=true"
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "288fac0d-84e8-400a-b23e-f3f3a6103cac"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=288fac0d-84e8-400a-b23e-f3f3a6103cac;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                         =  "Data Source=sapience-load-us-load.database.windows.net;Database=Admin;User=appsvc_api_user;Password=Khm8f426GxXf3x;"  
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  "true"
      WEBSITE_RUN_FROM_PACKAGE                 =  "1"

  }
}

resource "azurerm_storage_account" "sapience_functions_admin_support_api" {
  name                     = "sapadminsupapi${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_storage_account" "sapience_functions_notifications" {
  name                     = "sapiencenotifn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "288fac0d-84e8-400a-b23e-f3f3a6103cac"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=288fac0d-84e8-400a-b23e-f3f3a6103cac;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  "true"
      WEBSITE_RUN_FROM_PACKAGE                 =  "1"        
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=3AkE0cUNsRt/xIq3mTta2eBK2rSwVoruxQ6NyHD9exc=;"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=ZUc+7t1djM/bWavVE3FR+x2NGv0MncIgV2EClARvMCI=;"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=uGlnbfh7J35D5DFwSMM6ULJiFv7aYvRdF4eA4SuF08g=;"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=pbiOoEamOtx4SxUl/b9YQBCAkINtq8sEQv7OKBpPp7Q=;"
  }
}

resource "azurerm_function_app" "bulk_upload" {
  name                      = "azure-admin-bulk-upload-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_bulk_upload_plan_admin_users.id
  storage_connection_string = azurerm_storage_account.sapience_bulk_upload_admin_users_fn.primary_connection_string
  version                   = "3.1"
  app_settings              = {
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  "true"
      WEBSITE_RUN_FROM_PACKAGE                 =  "1"
      "FUNCTIONS_WORKER_RUNTIME"                 = "dotnet"
      "Integration:ConnString"                   =  "mongodb://sapience-integration-mongodb-load-us-load:1gBUYEv0P61mrP8l7KyHdd0f7vCwN1VeGp3H2wDO0Q33JauxItRIBsoxYW01QCrQTfJjiiGaNK7nVNxaaCAWaA==@sapience-integration-mongodb-load-us-load.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-load-us-load@"
      "Integration:DatabaseName"                 =  "Test"
      "Integration:Collections:IntegrationEvents" =  "Integration_Events"
      "IdentityProvider:Issuer"                  =  "https://sapience-load-us-load.auth0.com/"
      "IdentityProvider:Audience"                =  "https://api.sapienceanalytics.com" 
      "ApplicationInsights:InstrumentationKey"   =  "288fac0d-84e8-400a-b23e-f3f3a6103cac"
      "AzureServiceBus:Endpoint"                 =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=KzggZ7ksDIiPqA2tBPC4dKhVEyx/tFjbwNOgfScVzzU=;"
      "AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      "AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-load-us-load.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=e7RAJ4FN7d0fLTr/lwkORZHEtIfOA6/zy+IEQQGXBNk=;"
      "AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      "Auth0:Authority"                          =  "https://sapience-load-us-load.auth0.com/"
      "Auth0:Audience"                           =  "https://api.sapienceanalytics.com"
      "Auth0:ClientId"                           =  "NJa0UdhJ8v9XqNHz8jroF7dS2QCr0Zm0"
      "Auth0:Connection"                         =  "Username-Password-Authentication"
      "Auth0:PingUri"                            =  "https://sapience-load-us-load.auth0.com/test"
      "Sisense:BaseUrl"                          =  "https://sisense-linux.load.sapienceanalytics.com/"
      "Sisense:Secret"                           =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiYTBjNjExOTI4YWExYjY4Zjg0MmM0IiwiYXBpU2VjcmV0IjoiN2E5MzgyMWUtOTQyMy1mMjhkLWU3YmQtMGU5ZjY3NTIxOTdkIiwiaWF0IjoxNjAxMzExNTMyfQ.w2Mgj6ELPUwo5tQat7U-HafWqY11vquC2rE24HdBFVQ"
      "ConnectionStrings:Admin"                  =  "Data Source=sapience-load-us-load.database.windows.net;Database=Admin;User=appsvc_api_user;Password=Khm8f426GxXf3x;"
      #"ConnectionStrings:Staging"                =  "Data Source=sapience-lab-us-demo.database.windows.net;Database=Staging;User=appsvc_api_user;Password=kfguJEk29khwkKgi;"
      "UploadBlob:Container"                     =  "sapience-upload"
      "UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=saploadusbuload;AccountKey=Og22AZAQfTjap1mT9Tvsw4xNayPW30u0b1hW+n1iC6PwUaF//84NCJSJ44QKHUvFG6Iph120CFYj1a8N/7Pigg==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-load-us-load:sYP4y2M6r46o1J74nev55I36CbNGnAtLzC1evbZ2c5C71SAt1bVr81rcPFffZtaXeUtgcZul9lrsE395qZJbrA==@sapience-bulk-upload-mongodb-load-us-load.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      "BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
  }
}

resource "azurerm_storage_account" "sapience_bulk_upload_admin_users_fn" {
  name                     = "adminbufn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
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