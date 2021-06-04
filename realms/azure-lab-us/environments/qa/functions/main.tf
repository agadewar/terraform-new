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
      Sisense__BaseUrl                =  "https://sisense-linux.qa.sapienceanalytics.com/"
      Sisense__UsersUri               =  "api/users?email="
      Sisense__DefaultGroupUri        =  "api/v1/groups?name="
      Sisense__DataSecurityUri        =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri         =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource        =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource       =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                    =  "QA"
      Sisense__Secret                 =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiMTQwZTU2ZDY4MWQyMjQwYjhjYTk0IiwiYXBpU2VjcmV0IjoiMzBhMDNlZGUtZDU4OS0zMzcxLWYxZjktMDMyZjBiZGQ2MzdkIiwiaWF0IjoxNjA5ODQ2MTQ1fQ.NSNHwaCIfVl6YCmyvFCMuf_oD-EFNRb0IR4dCeNaAlg"
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

  app_settings                   = {
           "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = "true"
           "WEBSITE_RUN_FROM_PACKAGE"        = "1"
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

      app_settings                   = {
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      #AzureWebJobsStorage                    =  " "
      Connection                              =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=/PWQZJwtG9LOKdJG0xK1hHucIgB24GDqlj5nuWIuyNw="
      ConnectionString                        =  "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"  
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "0ljzI5jQnH9Fx8yQLxWxGdYOVQGRB4DY"
      Auth0__ManagementApiIdentifier          =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =  "https://qa-sapienceanalytics.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =  "https://qa-sapienceanalytics.auth0.com"
      Auth0__ManagementApiSecret              =  "KQiCawIg9O6LzN7r-ABbvq4kkaE0WfosK6nBhkW9uAwx5_lpe8BsB2HtTZMqE0Ka"
      Sisense__BaseUrl                        =  "https://sisense-linux.qa.sapienceanalytics.com/"
      Sisense__UsersUri                       =  "api/users?email="
      Sisense__DefaultGroupUri                =  "api/v1/groups?name="
      Sisense__DataSecurityUri                =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =  "QA"
      Sisense__Secret                         =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiMTQwZTU2ZDY4MWQyMjQwYjhjYTk0IiwiYXBpU2VjcmV0IjoiMzBhMDNlZGUtZDU4OS0zMzcxLWYxZjktMDMyZjBiZGQ2MzdkIiwiaWF0IjoxNjA5ODQ2MTQ1fQ.NSNHwaCIfVl6YCmyvFCMuf_oD-EFNRb0IR4dCeNaAlg"
      Canopy__Auth0Url                        =  "https://api.qa.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =  "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =  "https://api.qa.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=dOB3YaQvCn6JTveBMen29pr9Ugk9o3h3X50tYGiI6aw="
      EditConnection                          =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=1f8hCZFMPffFG7TUtv+JWMV94F+RgY1I3dgmlRh3xKc="
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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                         =  "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;" 
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  "true"
      WEBSITE_RUN_FROM_PACKAGE                 =  "1"

  }
}

resource "azurerm_storage_account" "sapience_functions_admin_support_api" {
  name                     = "sapadminsupapifn${replace(lower(var.realm), "-", "")}${var.environment}"
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
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=gccGmPC1aAPyc+SdHK7OyGjxQSVuCodwV+blcB7if28=;EntityPath=sapience-admin-activity-deleted"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=jxi0cU8bRkaWZvA34u/4b+r89PnJ/CAGJh/vJMOD/Ek=;EntityPath=sapience-admin-activity-updated"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=BGv2X/45vAWiqrOv7g5zJ96SvqdujcsdOSOLn+TVpTE=;EntityPath=sapience-admin-departments-deleted"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=SUI+iQWMS5JRwl+f53agq00aML2RBun0HCrmXCpLvJE=;EntityPath=sapience-admin-departments-updated"
  }
}