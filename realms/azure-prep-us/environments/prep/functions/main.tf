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
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "d11272a7-1401-4631-b755-1794906574f6"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=d11272a7-1401-4631-b755-1794906574f6;IngestionEndpoint=https://eastus-6.in.applicationinsights.azure.com/"  
      Connection                              =   "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=R7mNDOsYdyzlncahWgRdulzASKLHrwubV/lZkVTlZS4=;"
      ConnectionString                        =   "Data Source=sapience-prep-us-prep.database.windows.net;Database=Admin;User=appsvc_api_user;Password=gkyY9DhnB3cX55jKv4g"  
      FUNCTIONS_WORKER_RUNTIME                =   "dotnet"
      Auth0__Connection                       =   "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =   "ZzvhsGz6r6LPbWpw3Gk0Q1dMLNy5mnKL"
      Auth0__ManagementApiIdentifier          =   "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =   "https://sapience-prep-us-prep.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =   "https://sapience-prep-us-prep.auth0.com"
      Auth0__ManagementApiSecret              =   "toTKRGinKBMpb9ZqgPtKITyzM12w1P-lLiqLkvS8NiUReevpcIh1RvNj1zQuoBDZ"
      Sisense__BaseUrl                        =   "https://sapiencebi-prep-prep-us-azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =   "api/v1/users/bulk"
      Sisense__DefaultGroupUri                =   "api/v1/groups?name="
      Sisense__DataSecurityUri                =   "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =   "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =   "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =   "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =   "Prep"
      "Sisense__Server"                       =   "localhost"
      Sisense__SharedSecret                   =   "f1c57a66e12d916ea6e6c711d106c60c3efca58ad4237b571be36dd764d02caf"
      Sisense__Secret                         =   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkprtXVCJ9.eyJ1c2VyIjoiNWRjZGQ1YzBkYmMyZTEwNWQ0YjIzNDJiIiwiYXBpU2VjcmV0IjoiMmQ0NDFlODUtY2NlYy05YzBlLTQ3MTktN2IxY2M1YTk5YmY2IiwiaWF0IjoxNjExOTQzNzc5fQ.qBrRZsipEywKZoLZfcfLDF4Ybei-iSKzH8GUXndI_yw"
      Canopy__Auth0Url                        =   "https://api.prep.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =   "Sapience:sapience_adminservices:H#Qx6qbmafdafd1112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =   "https://api.prep.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =   "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=JyIiFrOIMqOtzq/wYmRv/o2rLcUaotplo+QeRM4iu0o="
      EditConnection                          =   "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=9Q+CcCj96ZO6WfQGubUshe3MxfkCxRfTdmzdFiFa/6s="
      "Sisense:EditUserUri"                   =   "api/v1/users/"
      "Sisense:GetDesignerRolesUri"           =   "api/roles/contributor"
      "Sisense:GetUserUri"                    =   "api/v1/users?email="
      "Sisense:GetViewerRolesUri"             =   "api/roles/consumer" 
      Sisense__DeleteUserUri                  =   "api/v1/users/"
      Sisense__EditUserUri                    =   "api/v1/users/"
      Sisense__GetUserUri                     =   "api/v1/users?email="
      WEBSITE_ENABLE_SYNC_UPDATE_SITE         =   true 
      WEBSITE_RUN_FROM_PACKAGE                =   "1" 
      "TeamCreatedConnection"                 = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=mh2uWhx4yfIu1Dd/39STPjit3fttFK4Lk+ZJztUjU6U=;"
      "TeamDeletedConnection"                 = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=2MFso4kEoHnsXmNt4Mbv6Fk9cbaO7uGI+09u62F9WhI=;"
      "TeamUpdatedConnection"                 = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=OROgWjEwY6k3beC/6y5TJGwCopoWF6KagmCDsXg9BuI=;"
      "UserActivatedConnection"               = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=MHh4YZlCOs99EFtU85DdqyRy5sJP7bLdx43lo5FwjLg=;"
      "UserDeactivatedConnection"             = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=VXPVCI1ILzCeWsJNCr2TLkk8UZDDggeTb7N9YYukllE=;"

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
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "d11272a7-1401-4631-b755-1794906574f6"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=d11272a7-1401-4631-b755-1794906574f6;IngestionEndpoint=https://eastus-6.in.applicationinsights.azure.com/"  
      Connection                              =   "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=R7mNDOsYdyzlncahWgRdulzASKLHrwubV/lZkVTlZS4=;"
      ConnectionString                        =   "Data Source=sapience-prep-us-prep.database.windows.net;Database=Admin;User=appsvc_api_user;Password=gkyY9DhnB3cX55jKv4g"  
      FUNCTIONS_WORKER_RUNTIME                =   "dotnet"
      Auth0__Connection                       =   "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =   "ZzvhsGz6r6LPbWpw3Gk0Q1dMLNy5mnKL"
      Auth0__ManagementApiIdentifier          =   "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =   "https://sapience-prep-us-prep.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =   "https://sapience-prep-us-prep.auth0.com"
      Auth0__ManagementApiSecret              =   "hy9J1imVKuK1OkBmVrNhNLIIQIp1FEpJL3Rd-dJsJMGozeQc9ruvRHagHHNvSkzQ"
      Sisense__BaseUrl                        =   "https://sisense.prep.prep.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =   "api/users?email="
      Sisense__DefaultGroupUri                =   "api/v1/groups?name="
      Sisense__DataSecurityUri                =   "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =   "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =   "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =   "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =   "Prep"
      Sisense__Secret                         =   "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abeyJ1c2VyIjoiNWRjZGQ1YzBkYmMyZTEwNWQ0YjIzNDJiIiwiYXBpU2VjcmV0IjoiMmQ0NDFlODUtY2NlYy05YzBlLTQ3MTktN2IxY2M1YTk5YmY2IiwiaWF0IjoxNTczNzcxMDU2fQ.55UdBA5jXCv1jbryo5T5hZLJq0GZfAlMoKUYlSRiVS8"
      Canopy__Auth0Url                        =   "https://api.prep.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =   "Sapience:sapience_AdminServices:H#Qx6qbmafdafd1112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =   "https://api.prep.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =   "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=JyIiFrOIMqOtzq/wYmRv/o2rLcUaotplo+QeRM4iu0o="
      EditConnection                          =   "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=9Q+CcCj96ZO6WfQGubUshe3MxfkCxRfTdmzdFiFa/6s="
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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "d11272a7-1401-4631-b755-1794906574f6"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=d11272a7-1401-4631-b755-1794906574f6;IngestionEndpoint=https://eastus-6.in.applicationinsights.azure.com/"  
      ConnectionString                         =  "Data Source=sapience-prep-us-prep.database.windows.net;Database=Admin;User=appsvc_api_user;Password=gkyY9DhnB3cX55jKv4g;"  
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
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=3SsoXu9GcDV+2v/S27xuhJ/jSDtvzqruMdJ8a2d+UUg=;EntityPath=sapience-admin-activity-deleted"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=Xjhbg92fDhc3svAxaBaJMJ+LNQb5qp6yoDz4WtrWxKw=;EntityPath=sapience-admin-activity-updated"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=BeLmPbR+rQmOOAEKcc5BveOm4ogEnQgpTPWCa2hjkGc=;EntityPath=sapience-admin-departments-deleted"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=NmylwE3XOpDH7g6d8SO8k6NFaXTPWSe5Tsik+k2pBtg=;EntityPath=sapience-admin-departments-updated"
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
      APPINSIGHTS_INSTRUMENTATIONKEY             =  "d11272a7-1401-4631-b755-1794906574f6"
      APPLICATIONINSIGHTS_CONNECTION_STRING      =  "InstrumentationKey=d11272a7-1401-4631-b755-1794906574f6;IngestionEndpoint=https://eastus-6.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE            =  true
      WEBSITE_RUN_FROM_PACKAGE                   =  1
      AzureServiceBus__TeamCreatedConnection     =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=mh2uWhx4yfIu1Dd/39STPjit3fttFK4Lk+ZJztUjU6U=;"
      AzureServiceBus__TeamUpdatedConnection     =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=OROgWjEwY6k3beC/6y5TJGwCopoWF6KagmCDsXg9BuI=;"
      "AzureServiceBus:UpdatedUsersEndpoint"     = "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=kqpz9iJJacOR8hT8bzSTbSqoibAh4g3+YGu8YlhSAQo=;"
      "AzureServiceBus:UpdatedUsersEntityPath"   = "sapience-admin-users-updated"      
      "AzureServiceBus:CreatedUsersEndpoint"     =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=R7mNDOsYdyzlncahWgRdulzASKLHrwubV/lZkVTlZS4=;"
      "AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      "AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-prep-us-prep.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=0Ge74SV1MqqG3WCRef8RIe7XquHrceAOn6JadgeATXs=;"
      "AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      "IdentityProvider:Issuer"                  =  "https://sapience-prep-us-prep.auth0.com/"
      "IdentityProvider:Audience"                =  "https://prep.us.prep.sapienceanalytics.com"
      "Auth0:Authority"                          =  "https://sapience-prep-us-prep.auth0.com/"
      "Auth0:Audience"                           =  "https://prep.us.prep.sapienceanalytics.com"
      "Auth0:ClientId"                           =  "Z0WJklJErXkHLo1OpGQzWYy6yUf84rFZ"
      "Auth0:Connection"                         =  "Username-Password-Authentication"
      "Auth0:PingUri"                            =  "https://sapience-prep-us-prep.auth0.com/test"
      "Sisense:BaseUrl"                          =  "https://sapiencebi-prep-prep-us-azure.sapienceanalytics.com/"
      "Sisense:Secret"                           =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abeyJ1c2VyIjoiNWRjZGQ1YzBkYmMyZTEwNWQ0YjIzNDJiIiwiYXBpU2VjcmV0IjoiMmQ0NDFlODUtY2NlYy05YzBlLTQ3MTktN2IxY2M1YTk5YmY2IiwiaWF0IjoxNjExOTQzNzc5fQ.qBrRZsipEywKZoLZfcfLDF4Ybei-iSKzH8GUXndI_yw"
      "ConnectionStrings:Admin"                  =  "Data Source=sapience-prep-us-prep.database.windows.net;Database=Admin;User=appsvc_api_user;Password=gkyY9DhnB3cX55jKv4g"
      "ConnectionStrings:Staging"                =  "Data Source=sapience-prep-us-prep.database.windows.net;Database=Staging;User=appsvc_api_user;Password=gkyY9DhnB3cX55jKv4g"
      "UploadBlob:Container"                     =  "sapience-upload"
      "UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=sapprepusbuprep;AccountKey=S43kfc2TjEPleNm21nfQdi3l0mGe1HX2hEhegtSs3AEtJNQNFlCmbR6JjlMzX+WK44x1yTPfFNDFbgGIXU+7Lw==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-prep-us-prep:itmFJPQO5ZdMxbymshgOyw2FaWNX70k1S7sJt1lWu5ObyHxWfyOxMGZz3aOPy3qkcBOWArw3PVRyLro1lVb3mg==@sapience-bulk-upload-mongodb-prep-us-prep.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      "BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
      "Integration:ConnString"                   =  "mongodb://sapience-integration-mongodb-prep-us-prep:wwnPsOfdh8YTfWBxyD7f7x5koC5UwIM1YjvfNxL7YoerxYjpiXhoBy4Tv5USDaUitRcbhZyP6SwQBRhX6p5Idg==@sapience-integration-mongodb-prep-us-prep.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "Integration:DatabaseName"                 =  "Test"
      "Integration:Collections:IntegrationEvents" =  "Integration_Events"
  }
}

resource "azurerm_storage_account" "sapience_functions_integration_teams" {
  name                     = "sapintteams${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_plan_integration_teams" {
  name                = "azure-function-service-plan-sap-intg-teams-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_sapience_integration_teams" {
  name                        = "azure-functions-app-sapience-integration-teams-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_integration_teams.id 
  storage_connection_string   = azurerm_storage_account.sapience_functions_integration_teams.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "d11272a7-1401-4631-b755-1794906574f6"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=d11272a7-1401-4631-b755-1794906574f6;IngestionEndpoint=https://eastus-6.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      "MongoDb__ConnectionString"              = "mongodb://sapience-integration-mongodb-prep-us-prep:wwnPsOfdh8YTfWBxyD7f7x5koC5UwIM1YjvfNxL7YoerxYjpiXhoBy4Tv5USDaUitRcbhZyP6SwQBRhX6p5Idg==@sapience-integration-mongodb-prep-us-prep.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-prep-us-prep@"
      "MongoDb__DatabaseName"                  = "Integrations"
      "MongoDb__Collection"                    = "MS_Teams_Calls"
  }
}