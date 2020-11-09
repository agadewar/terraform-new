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
  name                      = "azure-functions-app-sapience-user-provisioning-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_plan_admin_users.id
  #app_settings              = var.function_app_admin_users  
  storage_connection_string = azurerm_storage_account.sapience_functions_admin_users.primary_connection_string
  version                   = "3.1"

      app_settings                    = {
      AzureWebJobsStorage             =  "DefaultEndpointsProtocol=https;AccountName=adminfnlabusdev;AccountKey=q3ho7je4uBDiFN9p8HTz2r9d/BN6yPfF8qY1Ideon9BKYUFv0SgwNKQbmrRsNQ8EzXxq5gn9gvuvL4MAxe05bw==;EndpointSuffix=core.windows.net"
      Connection                      =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=qEBln4qcn9dz7oXi1Dqq8wn7/GrVsMYmvuuIS3JzwVw="
      FUNCTIONS_WORKER_RUNTIME        =  "dotnet"
      Auth0__Connection               =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId    =  "pGmGyQ49XNlCp8gd46a2cbEwC53xX4sj"
      Auth0__ManagementApiIdentifier  =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience    =  "https://dev-piin5umt.auth0.com/api/v2/"
      Auth0__ManagementApiSecret      =  "qYXiPQxH_fHXUU_uR6q7KWu8Eu2PrrkHnwW9WqGYx75IZZ9aMrrycaJwDf5EfNbI"
      Sisense__BaseUrl                =  "https://sisense.dev.lab.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri               =  "api/users?notify=false"
      Sisense__DefaultGroupUri        =  "api/v1/groups?name="
      Sisense__DataSecurityUri        =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri         =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource        =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource       =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                    =  "Dev"
      Sisense__Secret                 =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWY3ZDc3YjVkNmYwZjcyY2NjNmNkYTgzIiwiYXBpU2VjcmV0IjoiZTM4MmZjODAtMDNjYy1hNWYzLTgzMzItYzYzMDdjZThiZjljIiwiaWF0IjoxNjAyMDU4MTgyfQ._f8WkHANdTUkQDy9FLapthTHn_YoFKFqPpekSMezzGs"
      APPINSIGHTS_INSTRUMENTATIONKEY  =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                =   "Data Source=sapience-lab-us-dev.database.windows.net;Database=Admin;User=appsvc_api_user;Password=3HvaNxQEFvWThiZG;"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE  =  true
      WEBSITE_RUN_FROM_PACKAGE         =  1
      EditConnection                   =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=sUJBkqJpE8ouK0eagOSsigPA59ifpRPKbf032bXHRKo="
      DeleteConnection                 =  "Endpoint=sb://sapience-lab-us-dev.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=73LAxHOhxt4vPv91vUxDr5nq5djY0Nftsk3yGzQqs1A="
      Auth0__ManagementApiBaseUrl      =  "https://dev-piin5umt.auth0.com"

  }
}