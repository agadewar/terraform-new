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
      #Connection                               =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      #Auth0__Connection                        =  "Username-Password-Authentication"
      #Auth0__ManagementApiClientId             =  "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
      #Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      #Auth0__ManagementApiAudience             =  "https://sapience-lab-eu-dev.eu.auth0.com/api/v2/"
      #Auth0__ManagementApiSecret               =  "qYXiPQxH_fHXUU_uR6q7KWu8Eu2PrrkHnwW9WqGYx75IZZ9aMrrycaJwDf5EfNbI"
      #Sisense__BaseUrl                         =  "https://sisense-linux-ha.dev.sapienceanalytics.com/"
      #Sisense__UsersUri                        =  "api/v1/users/bulk"
      #Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      #Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      #Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      #Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      #Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      #Sisense__Env                             =  "Dev"
      #Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3MWMzZTRmNTg5M2YwMDJjOGM5MmIzIiwiYXBpU2VjcmV0IjoiMTY5N2E1ODgtZThiYS1iZDc5LTM1NTUtN2VlNGQ1ODRhMzYxIiwiaWF0IjoxNjAzNjA3ODAxfQ.ZG9i_H00xo7Kd9wGHcMaF_WyyDe7_LFCenp8iSa843U"
      #APPINSIGHTS_INSTRUMENTATIONKEY           =  "15ae11d2-60f2-4890-a2e0-90b496fe2f11"
      #APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=15ae11d2-60f2-4890-a2e0-90b496fe2f11;IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/"
      #ConnectionString                         =   "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
      #WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      #WEBSITE_RUN_FROM_PACKAGE                 =  1
      #EditConnection                           =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      #DeleteConnection                         =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      #Auth0__ManagementApiBaseUrl              =  "https://dev-piin5umt.auth0.com"
      #Canopy__Auth0Url                         =  "https://api.dev.sapienceanalytics.com/auth0/v1/integrations/auth0"
      #Canopy__Credentials                      =  "Sapience:steve.ardis@banyanhills.com:b@nyan!"
      #Canopy__UserServiceUrl                   =  "https://api.dev.sapienceanalytics.com/user/v1/users/"
      #"Sisense:EditUserUri"                    =  "api/v1/users/"
      #"Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      #"Sisense:GetUserUri"                     =  "api/v1/users?email="
      #"Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      #"Sisense__DeleteUserUri"                 =  "api/v1/users/"
      #"Sisense__OperatingSystem"               =  "linux"
      #"Sisense__Server"                        =  "localhost"
      "TeamCreatedConnection"                  = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=IFLPqXRJChHCmkVVKasigU+FS6QC9vu6edby47ALXAQ=;"
      "TeamDeletedConnection"                  = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=dlodv1vkFj4wMYq+DLMjwu5klqt8MH4049VsLPVzPN4=;"
      "TeamUpdatedConnection"                  = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=0oMgAeAmbCu/NlMj9Af8IQQrSydZgnPWIc8by2A+FJE=;"
      "UserActivatedConnection"                = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=QET/mcxnwelKmYIeWB/kR0QcnEnJ/23QUoIqrnEYPY8=;"
      "UserDeactivatedConnection"              = "Endpoint=sb://sapience-lab-eu-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=W8XpOQkRvQbyxfm6A+LH5yz1hu4uF6zlG5QDoI+jkao=;"


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
      #Auth0__Connection                        =  "Username-Password-Authentication"
      #Auth0__ManagementApiClientId             =  "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
      #Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      #Auth0__ManagementApiAudience             =  "https://sapience-lab-eu-dev.eu.auth0.com/api/v2/"
      #Auth0__ManagementApiSecret               =  "qYXiPQxH_fHXUU_uR6q7KWu8Eu2PrrkHnwW9WqGYx75IZZ9aMrrycaJwDf5EfNbI"
      #Sisense__BaseUrl                         =  "https://sisense-linux-ha.dev.sapienceanalytics.com/"
      #Sisense__UsersUri                        =  "api/v1/users/bulk"
      #Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      #Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      #Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      #Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      #Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      #Sisense__Env                             =  "Dev"
      #Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3MWMzZTRmNTg5M2YwMDJjOGM5MmIzIiwiYXBpU2VjcmV0IjoiMTY5N2E1ODgtZThiYS1iZDc5LTM1NTUtN2VlNGQ1ODRhMzYxIiwiaWF0IjoxNjAzNjA3ODAxfQ.ZG9i_H00xo7Kd9wGHcMaF_WyyDe7_LFCenp8iSa843U"
      #APPINSIGHTS_INSTRUMENTATIONKEY           =  "15ae11d2-60f2-4890-a2e0-90b496fe2f11"
      #APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=15ae11d2-60f2-4890-a2e0-90b496fe2f11;IngestionEndpoint=https://northeurope-0.in.applicationinsights.azure.com/"
      #ConnectionString                         =  "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_tenant_user;Password=hQkWTfF34JHCdn;"
      #WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      #WEBSITE_RUN_FROM_PACKAGE                 =  1
      #EditConnection                           =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      #DeleteConnection                         =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      #Auth0__ManagementApiBaseUrl              =  "https://dev-piin5umt.auth0.com"
      #Canopy__Auth0Url                         =  "https://api.dev.sapienceanalytics.com/auth0/v1/integrations/auth0"
      #Canopy__Credentials                      =  "Sapience:steve.ardis@banyanhills.com:b@nyan!"
      #Canopy__UserServiceUrl                   =  "https://api.dev.sapienceanalytics.com/user/v1/users/"
      #"Sisense:EditUserUri"                    =  "api/v1/users/"
      #"Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      #"Sisense:GetUserUri"                     =  "api/v1/users?email="
      #"Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      #"Sisense__DeleteUserUri"                 =  "api/v1/users/"
      #"Sisense__OperatingSystem"               =  "linux"
      #"Sisense__Server"                        =  "localhost"
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
      #ConnectionString                         =  "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
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
      #WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      #WEBSITE_RUN_FROM_PACKAGE                 =  1
      #"AzureServiceBus:Endpoint"                 =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=jEcxjwnTChnuMisdsw7xgBUIANE+Kris1IA2Urxmndg="
      #"AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      #"AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=kdbQ/M3CZzEIagskM8/JetX3LMuePgnF2xbcYgfIGAE="
      #"AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      #"IdentityProvider:Issuer"                  =  "https://login.dev.lab.sapienceanalytics.com/"
      #"IdentityProvider:Audience"                =  "https://api.sapienceanalytics.com"
      #"Auth0:Authority"                          =  "https://login.dev.lab.sapienceanalytics.com/"
      #"Auth0:Audience"                           =  "https://api.sapienceanalytics.com"
      #"Auth0:ClientId"                           =  "gEurUe965S21CvJyQtArQ3z8TahgC20K"
      #"Auth0:Connection"                         =  "Username-Password-Authentication"
      #"Auth0:PingUri"                            =  "https://login.dev.lab.sapienceanalytics.com/test"
      #"Sisense:BaseUrl"                          =  "https://sisense.dev.lab.us.azure.sapienceanalytics.com/"
      #"Sisense:Secret"                           =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3ZDc3YjVkNmYwZjcyY2NjNmNkYTgzIiwiYXBpU2VjcmV0IjoiZTM4MmZjODAtMDNjYy1hNWYzLTgzMzItYzYzMDdjZThiZjljIiwiaWF0IjoxNjAyMDU4MTgyfQ._f8WkHANdTUkQDy9FLapthTHn_YoFKFqPpekSMezzGs"
      #"ConnectionStrings:Admin"                  =  "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG"
      #"ConnectionStrings:Staging"                =  "Data Source=sapience-lab-us-dev.database.windows.net;Database=Staging;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
      #"UploadBlob:Container"                     = "sapience-upload"
      #"UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=saplabusbudev;AccountKey=qyTqudSpn0Fcn5UxCoGxcqRcsYVUdwk8b+AdwC+cbop8hdADOgPCGl/Y1ZREZdaLxrlHX89yiSjTKB245syNHg==;EndpointSuffix=core.windows.net"
      #"BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-lab-us-dev:pHv2SDPSjUBawX8naxFUjscBddy4OtAGYAoV6NaKfFac4XENl9g5Cm7akCZaoabaY2WpRDaCFSzYAuceXjbthg==@sapience-bulk-upload-mongodb-lab-us-dev.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"
      #"BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      #"BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
      #"Integration:ConnString"                   =  "AccountEndpoint=mongodb+srv://vueintegrationpoc-integration1:NXWgN53WZph6Y0xEugvdRI0Kboqr6Y44GhqqkDwXYy60xGrvlCqAM2aIK0l4cwyWqAggBEpFZ4KRteCnxlyi2g==@vueintegrationpoc-integration1.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@vueintegrationpoc-integration1@;AccountKey=NXWgN53WZph6Y0xEugvdRI0Kboqr6Y44GhqqkDwXYy60xGrvlCqAM2aIK0l4cwyWqAggBEpFZ4KRteCnxlyi2g=="
      #"Integration:DatabaseName"                =  "Test"
      #"Integration:Collections:IntegrationEvents" =  "Integration_Events"
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
      #"ActivityDeletedConnection"              = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=i66WcMlsln+x12qIDszybU092Bsh+fczF9IWjQMnM3o=;EntityPath=sapience-admin-activity-deleted"
      #"ActivityUpdatedConnection"              = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=yPMYDc5bJ+ekAfWxTaKCL2TuW6XszlNxC456Qfck0zc=;EntityPath=sapience-admin-activity-updated"
      #"DepartmentDeletedConnection"            = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=Yhd7jGiwtg54ts6/l4XnGOkK+6S0ROQghEQlglbX+D0=;EntityPath=sapience-admin-departments-deleted"
      #"DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=+Y7ePPO5cRc7iYonxfHlS/1koVIvK1ELV51lyQ5b+9w=;EntityPath=sapience-admin-departments-updated"
  }
}