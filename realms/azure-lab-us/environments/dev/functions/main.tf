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
  app_settings              = var.function_app_settings
  storage_connection_string = azurerm_storage_account.sapience_functions.primary_connection_string
  # storage_connection_string = data.terraform_remote_state.storage_account.outputs.primary_connection_string
  version                   = "~2"
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
  name                        = "azure-functions-app-sapience-user-provisioning-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_admin_users.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string   = azurerm_storage_account.sapience_functions_admin_users.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      #AzureWebJobsStorage                     =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      Connection                               =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      Auth0__Connection                        =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId             =  "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
      Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience             =  "https://dev-piin5umt.auth0.com/api/v2/"
      Auth0__ManagementApiSecret               =  "qYXiPQxH_fHXUU_uR6q7KWu8Eu2PrrkHnwW9WqGYx75IZZ9aMrrycaJwDf5EfNbI"
      Sisense__BaseUrl                         =  "https://sisense-linux-ha.dev.sapienceanalytics.com/"
      Sisense__UsersUri                        =  "api/v1/users/bulk"
      Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                             =  "Dev"
      Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3MWMzZTRmNTg5M2YwMDJjOGM5MmIzIiwiYXBpU2VjcmV0IjoiMTY5N2E1ODgtZThiYS1iZDc5LTM1NTUtN2VlNGQ1ODRhMzYxIiwiaWF0IjoxNjAzNjA3ODAxfQ.ZG9i_H00xo7Kd9wGHcMaF_WyyDe7_LFCenp8iSa843U"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                         =   "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      EditConnection                           =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      DeleteConnection                         =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      Auth0__ManagementApiBaseUrl              =  "https://dev-piin5umt.auth0.com"
      Canopy__Auth0Url                         =  "https://api.dev.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                      =  "Sapience:steve.ardis@banyanhills.com:b@nyan!"
      Canopy__UserServiceUrl                   =  "https://api.dev.sapienceanalytics.com/user/v1/users/"
      "Sisense:EditUserUri"                    =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      "Sisense:GetUserUri"                     =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      "Sisense__DeleteUserUri"                 =  "api/v1/users/"
      "Sisense__OperatingSystem"               =  "linux"
      "Sisense__Server"                        =  "localhost"
      "TeamCreatedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=Y8FqqDBBUoo7siuhNzNgnAl7Ijv0cvW1CoM9nPC0RDI="
      "TeamDeletedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=subscribe;SharedAccessKey=cPVXfbWm3xxoECbsQMKZwevVg+oQyk/yLcLncSxfILQ=;"
      "TeamUpdatedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=a6DXRehepa/YBydWu1Wx68wLGc0E2ecLqb5RYYMi45k=;"
      "UserActivatedConnection"                = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=subscribe;SharedAccessKey=Lc8oE7XlFGx28a9E/ZpK/oJ3nxhaxDxNlP12M7J4QIc=;"
      "UserDeactivatedConnection"             = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=cxD/zxYMutKbLjpAplpzku655ulxtTM4nUc02ZytcmI=;"


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
  location                 = "eastus2"
  account_tier             = "Standard"
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

      app_settings                             = {
      #AzureWebJobsStorage                     =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      Connection                               =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      Auth0__Connection                        =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId             =  "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
      Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience             =  "https://dev-piin5umt.auth0.com/api/v2/"
      Auth0__ManagementApiSecret               =  "qYXiPQxH_fHXUU_uR6q7KWu8Eu2PrrkHnwW9WqGYx75IZZ9aMrrycaJwDf5EfNbI"
      Sisense__BaseUrl                         =  "https://sisense-linux-ha.dev.sapienceanalytics.com/"
      Sisense__UsersUri                        =  "api/v1/users/bulk"
      Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                             =  "Dev"
      Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3MWMzZTRmNTg5M2YwMDJjOGM5MmIzIiwiYXBpU2VjcmV0IjoiMTY5N2E1ODgtZThiYS1iZDc5LTM1NTUtN2VlNGQ1ODRhMzYxIiwiaWF0IjoxNjAzNjA3ODAxfQ.ZG9i_H00xo7Kd9wGHcMaF_WyyDe7_LFCenp8iSa843U"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                         =   "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      EditConnection                           =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      DeleteConnection                         =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      Auth0__ManagementApiBaseUrl              =  "https://dev-piin5umt.auth0.com"
      Canopy__Auth0Url                         =  "https://api.dev.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                      =  "Sapience:steve.ardis@banyanhills.com:b@nyan!"
      Canopy__UserServiceUrl                   =  "https://api.dev.sapienceanalytics.com/user/v1/users/"
      "Sisense:EditUserUri"                    =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      "Sisense:GetUserUri"                     =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      "Sisense__DeleteUserUri"                 =  "api/v1/users/"
      "Sisense__OperatingSystem"               =  "linux"
      "Sisense__Server"                        =  "localhost"
      "TeamCreatedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=Y8FqqDBBUoo7siuhNzNgnAl7Ijv0cvW1CoM9nPC0RDI="
      "TeamDeletedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=subscribe;SharedAccessKey=cPVXfbWm3xxoECbsQMKZwevVg+oQyk/yLcLncSxfILQ=;"
      "TeamUpdatedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=a6DXRehepa/YBydWu1Wx68wLGc0E2ecLqb5RYYMi45k=;"
      "UserActivatedConnection"                = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=subscribe;SharedAccessKey=Lc8oE7XlFGx28a9E/ZpK/oJ3nxhaxDxNlP12M7J4QIc=;"
      "UserDeactivatedConnection"             = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=cxD/zxYMutKbLjpAplpzku655ulxtTM4nUc02ZytcmI=;"

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
      #AzureWebJobsStorage                     =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      Connection                               =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      Auth0__Connection                        =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId             =  "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
      Auth0__ManagementApiIdentifier           =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience             =  "https://dev-piin5umt.auth0.com/api/v2/"
      Auth0__ManagementApiSecret               =  "qYXiPQxH_fHXUU_uR6q7KWu8Eu2PrrkHnwW9WqGYx75IZZ9aMrrycaJwDf5EfNbI"
      Sisense__BaseUrl                         =  "https://sisense-linux-ha.dev.sapienceanalytics.com/"
      Sisense__UsersUri                        =  "api/v1/users/bulk"
      Sisense__DefaultGroupUri                 =  "api/v1/groups?name="
      Sisense__DataSecurityUri                 =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                  =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                 =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource                =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                             =  "Dev"
      Sisense__Secret                          =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3MWMzZTRmNTg5M2YwMDJjOGM5MmIzIiwiYXBpU2VjcmV0IjoiMTY5N2E1ODgtZThiYS1iZDc5LTM1NTUtN2VlNGQ1ODRhMzYxIiwiaWF0IjoxNjAzNjA3ODAxfQ.ZG9i_H00xo7Kd9wGHcMaF_WyyDe7_LFCenp8iSa843U"
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                         =   "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      EditConnection                           =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      DeleteConnection                         =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      Auth0__ManagementApiBaseUrl              =  "https://dev-piin5umt.auth0.com"
      Canopy__Auth0Url                         =  "https://api.dev.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                      =  "Sapience:steve.ardis@banyanhills.com:b@nyan!"
      Canopy__UserServiceUrl                   =  "https://api.dev.sapienceanalytics.com/user/v1/users/"
      "Sisense:EditUserUri"                    =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"            =  "api/roles/contributor"
      "Sisense:GetUserUri"                     =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"              =  "api/roles/consumer"
      "Sisense__DeleteUserUri"                 =  "api/v1/users/"
      "Sisense__OperatingSystem"               =  "linux"
      "Sisense__Server"                        =  "localhost"
      "TeamCreatedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=Y8FqqDBBUoo7siuhNzNgnAl7Ijv0cvW1CoM9nPC0RDI="
      "TeamDeletedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=subscribe;SharedAccessKey=cPVXfbWm3xxoECbsQMKZwevVg+oQyk/yLcLncSxfILQ=;"
      "TeamUpdatedConnection"                  = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=a6DXRehepa/YBydWu1Wx68wLGc0E2ecLqb5RYYMi45k=;"
      "UserActivatedConnection"                = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=subscribe;SharedAccessKey=Lc8oE7XlFGx28a9E/ZpK/oJ3nxhaxDxNlP12M7J4QIc=;"
      "UserDeactivatedConnection"             = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=cxD/zxYMutKbLjpAplpzku655ulxtTM4nUc02ZytcmI=;"

  }
}

resource "azurerm_storage_account" "sapience_functions_admin_support_api" {
  name                     = "sapadminsupapifn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}

resource "azurerm_app_service_plan" "service_plan_admin_core" {
  name                = "azure-fun-service-plan-sap-admin-core-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "function_app_sapience_admin_core" {
  name                        = "azure-functions-app-sapience-admin-core-${var.realm}-${var.environment}"
  resource_group_name         = var.resource_group_name
  location                    = var.resource_group_location
  app_service_plan_id         = azurerm_app_service_plan.service_plan_admin_core.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string   = azurerm_storage_account.sapience_functions_admin_core.primary_connection_string
  version                     = "3.1"

      app_settings                             = {
      #AzureWebJobsStorage                     =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      Connection                               =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME                 =  "dotnet"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      AzureServiceBus__UserCreatedEndpoint     = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=jEcxjwnTChnuMisdsw7xgBUIANE+Kris1IA2Urxmndg=;"
      AzureServiceBus__UserDeletedEndpoint     = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=kdbQ/M3CZzEIagskM8/JetX3LMuePgnF2xbcYgfIGAE=;"
      AzureServiceBus__UserUpdatedEndpoint     = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=gvUAH44wcLG8sQYgryDiMD/xV6x6815IcH8kbpSQiGg=;"
      AzureServiceBus__UserActivatedEndpoint   = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=publish;SharedAccessKey=XyW35jJ4tiub8u6/534TsHGDQh9R+KWpYgeiqcg2GGg=;"
      AzureServiceBus__UserDeactivatedEndpoint = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=eHXbRzk793rBhXvBsLnZsWwefqeHbHUXUzSA3+/TlWA=;"
      AzureServiceBus__TeamCreatedEndpoint     = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=leQbckeauyGd+EWoSFu6lDpUKp6iV8f+iGwpF/ilQIs=;"
      AzureServiceBus__TeamDeletedEndpoint     = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=publish;SharedAccessKey=4v0D0eo8siBNMRngjEi/95pyG6GyclXJn7BE+4Mklak=;"
      AzureServiceBus__TeamUpdatedEndpoint     = "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=LGu3q9Ex0CThsy8k1aMTCAcS6blWHMd3/riJhs4WZnE=;"
      ConnectionString                         = "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
  }
}

resource "azurerm_storage_account" "sapience_functions_admin_core" {
  name                     = "sapadmincorefn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = merge(local.common_tags, {})
}