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

      app_settings                   = {
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      #AzureWebJobsStorage                    =  " "
      Connection                              =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=/PWQZJwtG9LOKdJG0xK1hHucIgB24GDqlj5nuWIuyNw="
      ConnectionString                        = "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"  
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "0ljzI5jQnH9Fx8yQLxWxGdYOVQGRB4DY"
      Auth0__ManagementApiIdentifier  = "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience    =  "https://qa-sapienceanalytics.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl     =  "https://qa-sapienceanalytics.auth0.com"
      Auth0__ManagementApiSecret      =  "KQiCawIg9O6LzN7r-ABbvq4kkaE0WfosK6nBhkW9uAwx5_lpe8BsB2HtTZMqE0Ka"
      Sisense__BaseUrl                =  "https://sisense.qa.lab.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri               =  "api/users?email="
      Sisense__DefaultGroupUri        =  "api/v1/groups?name="
      Sisense__DataSecurityUri        =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri         =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource        =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource       =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                    =  "Qa"
      Sisense__Secret                 =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiMWE4ZDZmYjZkMTEyMjMwMzJjYTQ5IiwiYXBpU2VjcmV0IjoiNmZhNzY2N2EtOWYxOC0zYTAwLWI4MGEtZmMxMmJjMDc5NTFjIiwiaWF0IjoxNTcxOTI0MzM3fQ.zLLGdMAri0s_NcGei3S8JYg956qPPHnNVneIZLprbno"
      Canopy__Auth0Url                =  "https://api.qa.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials             =  "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl          =  "https://api.qa.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=dOB3YaQvCn6JTveBMen29pr9Ugk9o3h3X50tYGiI6aw="
      EditConnection                  =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=1f8hCZFMPffFG7TUtv+JWMV94F+RgY1I3dgmlRh3xKc="
      "Sisense:EditUserUri"           =  "api/v1/users/"
      "Sisense:GetDesignerRolesUri"   =  "api/roles/contributor"
      "Sisense:GetUserUri"            =  "api/v1/users?email="
      "Sisense:GetViewerRolesUri"     =  "api/roles/consumer" 
      Sisense__DeleteUserUri          =  "api/v1/users/"
      Sisense__EditUserUri            =  "api/v1/users/"
      Sisense__GetUserUri             =  "api/v1/users?email="
      WEBSITE_ENABLE_SYNC_UPDATE_SITE =  true 
      WEBSITE_RUN_FROM_PACKAGE        =  "1" 


  }
}

resource "azurerm_function_app" "bulk_upload" {
  name                      = "azure-admin-bulk-upload-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_bulk_upload_plan_admin_users.id
  storage_connection_string = azurerm_storage_account.sapience_bulk_upload_admin_users.primary_connection_string
  version                   = "~2"
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
