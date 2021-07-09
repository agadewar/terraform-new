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

resource "azurerm_storage_account" "sapience_functions" {
  name                     = "sapfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

# resource "azurerm_storage_account" "azure_web_jobs_storage" {
#   name                     = "sapiencewebjobs${var.environment}"
#   resource_group_name      = "${var.resource_group_name}"
#   location                 = "eastus2"
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = "${merge(
#     local.common_tags,
#     map()
#   )}"
# }

resource "azurerm_app_service_plan" "service_plan" {
  name                = "azure-functions-service-plan-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                      = "azure-functions-app-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_plan.id
  storage_connection_string = azurerm_storage_account.sapience_functions.primary_connection_string
  # storage_connection_string = data.terraform_remote_state.storage_account.outputs.primary_connection_string
  version                   = "~2"
  app_settings              = var.function_app_settings
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
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "16515cc7-b0ef-487c-9cff-d85ce3b24c44"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=16515cc7-b0ef-487c-9cff-d85ce3b24c44;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      Connection                              =   "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=/2nfbLFXJOGVb18xT/ZLgpXYGfpsMi9PCBE3CeMUTsg=;"
      ConnectionString                        =   "Data Source=sapience-prod-us-prod.database.windows.net;Database=Admin;User=appsvc_api_user;Password=AZoZtwZych+n}991umI;"  
      FUNCTIONS_WORKER_RUNTIME                =   "dotnet"
      Auth0__Connection                       =   "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =   "HfQ8y3WywURrxDU2JEgYgQlP0da12Ihv"
      Auth0__ManagementApiIdentifier          =   "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =   "https://sapience-prod-us-prod.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =   "https://sapience-prod-us-prod.auth0.com"
      Auth0__ManagementApiSecret              =   "hy9J1imVKuK1OkBmVrNhNLIIQIp1FEpJL3Rd-dJsJMGozeQc9ruvRHagHHNvSkzQ"
      Sisense__BaseUrl                        =   "https://sisense.prod.prod.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =   "api/users?email="
      Sisense__DefaultGroupUri                =   "api/v1/groups?name="
      Sisense__DataSecurityUri                =   "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =   "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =   "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =   "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =   "Prod"
      Sisense__Secret                         =   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRjZGQ1YzBkYmMyZTEwNWQ0YjIzNDJiIiwiYXBpU2VjcmV0IjoiMmQ0NDFlODUtY2NlYy05YzBlLTQ3MTktN2IxY2M1YTk5YmY2IiwiaWF0IjoxNTczNzcxMDU2fQ.55UdBA5jXCv1jbryo5T5hZLJq0GZfAlMoKUYlSRiVS8"
      Canopy__Auth0Url                        =   "https://api.prod.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =   "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =   "https://api.prod.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =   "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=I0SPY/91uh/fwGAn8FI++mvKs+GNorXsFhhluhvRccg="
      EditConnection                          =   "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=RTMP/wTWoL4TftZV8m9cHcwwT3yhGlt2auFw/vEoAVc="
      "Sisense:EditUserUri"                   =   "api/v1/users/"
      "Sisense:GetDesignerRolesUri"           =   "api/roles/contributor"
      "Sisense:GetUserUri"                    =   "api/v1/users?email="
      "Sisense:GetViewerRolesUri"             =   "api/roles/consumer" 
      Sisense__DeleteUserUri                  =   "api/v1/users/"
      Sisense__EditUserUri                    =   "api/v1/users/"
      Sisense__GetUserUri                     =   "api/v1/users?email="
      WEBSITE_ENABLE_SYNC_UPDATE_SITE         =   true 
      WEBSITE_RUN_FROM_PACKAGE                =   "1" 

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
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "16515cc7-b0ef-487c-9cff-d85ce3b24c44"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=16515cc7-b0ef-487c-9cff-d85ce3b24c44;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      Connection                              =   "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=/2nfbLFXJOGVb18xT/ZLgpXYGfpsMi9PCBE3CeMUTsg=;"
      ConnectionString                        =   "Data Source=sapience-prod-us-prod.database.windows.net;Database=Admin;User=appsvc_api_user;Password=AZoZtwZych+n}991umI;"  
      FUNCTIONS_WORKER_RUNTIME                =   "dotnet"
      Auth0__Connection                       =   "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =   "HfQ8y3WywURrxDU2JEgYgQlP0da12Ihv"
      Auth0__ManagementApiIdentifier          =   "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =   "https://sapience-prod-us-prod.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =   "https://sapience-prod-us-prod.auth0.com"
      Auth0__ManagementApiSecret              =   "hy9J1imVKuK1OkBmVrNhNLIIQIp1FEpJL3Rd-dJsJMGozeQc9ruvRHagHHNvSkzQ"
      Sisense__BaseUrl                        =   "https://sisense.prod.prod.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =   "api/users?email="
      Sisense__DefaultGroupUri                =   "api/v1/groups?name="
      Sisense__DataSecurityUri                =   "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =   "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =   "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =   "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =   "Prod"
      Sisense__Secret                         =   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRjZGQ1YzBkYmMyZTEwNWQ0YjIzNDJiIiwiYXBpU2VjcmV0IjoiMmQ0NDFlODUtY2NlYy05YzBlLTQ3MTktN2IxY2M1YTk5YmY2IiwiaWF0IjoxNTczNzcxMDU2fQ.55UdBA5jXCv1jbryo5T5hZLJq0GZfAlMoKUYlSRiVS8"
      Canopy__Auth0Url                        =   "https://api.prod.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =   "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =   "https://api.prod.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =   "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=I0SPY/91uh/fwGAn8FI++mvKs+GNorXsFhhluhvRccg="
      EditConnection                          =   "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=RTMP/wTWoL4TftZV8m9cHcwwT3yhGlt2auFw/vEoAVc="
      "Sisense:EditUserUri"                   =   "api/v1/users/"
      "Sisense:GetDesignerRolesUri"           =   "api/roles/contributor"
      "Sisense:GetUserUri"                    =   "api/v1/users?email="
      "Sisense:GetViewerRolesUri"             =   "api/roles/consumer" 
      Sisense__DeleteUserUri                  =   "api/v1/users/"
      Sisense__EditUserUri                    =   "api/v1/users/"
      Sisense__GetUserUri                     =   "api/v1/users?email="
      WEBSITE_ENABLE_SYNC_UPDATE_SITE         =   true 
      WEBSITE_RUN_FROM_PACKAGE                =   "1" 

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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "16515cc7-b0ef-487c-9cff-d85ce3b24c44"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=16515cc7-b0ef-487c-9cff-d85ce3b24c44;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      ConnectionString                         =  "Data Source=sapience-prod-us-prod.database.windows.net;Database=Admin;User=appsvc_api_user;Password=AZoZtwZych+n}991umI;"  
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
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qvwdEjNGQCye1K/aw7MW0F8ogU1+qHqy/TV/njtsdqw=;EntityPath=sapience-admin-activity-deleted"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=efuxOL5Kuv9wWy6gJhm2C6FRzDADcs/Nwp6vK3pBvzk=;EntityPath=sapience-admin-activity-updated"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=51uwsDqKnGyK+iuTLMy+XHY9b5MUPxXuTkMgeYkBNpI=;EntityPath=sapience-admin-departments-deleted"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=jhw0svhiKbHcqa9N1zFAkbIl1YtrTpRa6HshsxEy64M=;EntityPath=sapience-admin-departments-updated"
  }
}

resource "azurerm_storage_account" "sapience_functions_admin_int_api" {
  name                     = "sapadminintapi${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
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
      APPINSIGHTS_INSTRUMENTATIONKEY             =  "16515cc7-b0ef-487c-9cff-d85ce3b24c44"
      APPLICATIONINSIGHTS_CONNECTION_STRING      =  "InstrumentationKey=16515cc7-b0ef-487c-9cff-d85ce3b24c44;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE            =  true
      WEBSITE_RUN_FROM_PACKAGE                   =  1
      "AzureServiceBus:Endpoint"                 =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=5qUDVqkfHhmGS+KYIAnuvYEMU3N+CrcxiUhfI8t9kT0=;"
      "AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      "AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-prod-us-prod.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=Jip9weAu9AbCQ2f0KsNeaSBlNWaSn+hCwyfKq7U+gFk=;"
      "AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      "IdentityProvider:Issuer"                  =  "https://sapience-prod-us-prod.auth0.com/"
      "IdentityProvider:Audience"                =  "https://prod.us.prod.sapienceanalytics.com"
      "Auth0:Authority"                          =  "https://sapience-prod-us-prod.auth0.com/"
      "Auth0:Audience"                           =  "https://prod.us.prod.sapienceanalytics.com"
      "Auth0:ClientId"                           =  "mk3ftdtiPis6dkRv0Sxy6gvFxsjZTs3e"
      "Auth0:Connection"                         =  "Username-Password-Authentication"
      "Auth0:PingUri"                            =  "https://sapience-prod-us-prod.auth0.com/test"
      "Sisense:BaseUrl"                          =  "https://sapiencebi.sapienceanalytics.com/"
      "Sisense:Secret"                           =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRjZGQ1YzBkYmMyZTEwNWQ0YjIzNDJiIiwiYXBpU2VjcmV0IjoiMmQ0NDFlODUtY2NlYy05YzBlLTQ3MTktN2IxY2M1YTk5YmY2IiwiaWF0IjoxNjExOTQzNzc5fQ.qBrRZsipEywKZoLZfcfLDF4Ybei-iSKzH8GUXndI_yw"
      "ConnectionStrings:Admin"                  =  "Data Source=sapience-prod-us-prod.database.windows.net;Database=Admin;User=appsvc_api_user;Password=AZoZtwZych+n}991umI;"
      "ConnectionStrings:Staging"                =  "Data Source=sapience-prod-us-prod.database.windows.net;Database=Staging;User=appsvc_api_user;Password=AZoZtwZych+n}991umI;"
      "UploadBlob:Container"                     =  "sapience-upload"
      "UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=sapprodusbuprod;AccountKey=nOERUaQGyYHpSVJHfaGxNM+CY2Y9uq4nVG0QnJpnSsncoPJ/saEnKlv2ydFoLUjTyy6+L3wNiajFHo7Ntph63Q==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-prod-us-prod:Nv7gyM3WPLwOsIIkyFLIH2ctlZ1iaLv49qp3MPIy1xjl63w2is7CrOOOAJV1pWdhFCJSMFAEU3Q19eQfEAgMHA==@sapience-bulk-upload-mongodb-prod-us-prod.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      "BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
      "Integration:ConnString"                   =  "mongodb://sapience-integration-mongodb-prod-us-prod:bAR9EDQzFQkTxUFbyy6dwYEVxFCAJuJATjnHwfj3knlitGy8L60Vc2aQfBuZGoRAzFm7ZlfPCA2BrkcRSQABDQ==@sapience-integration-mongodb-prod-us-prod.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-prod-us-prod@"
      "Integration:DatabaseName"                 =  "Test"
      "Integration:Collections:IntegrationEvents" =  "Integration_Events"
  }
}