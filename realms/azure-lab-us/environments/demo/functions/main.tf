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

# resource "azurerm_storage_account" "sapience_functions" {
#   name                     = "sapfn${replace(lower(var.realm), "-", "")}${var.environment}"
#   resource_group_name      = var.resource_group_name
#   location                 = "eastus2"
#   account_tier             = "Standard"
#   account_replication_type = "GRS"

#   tags = merge(local.common_tags, {})
# }

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

# resource "azurerm_app_service_plan" "service_plan" {
#   name                = "azure-functions-service-plan-${var.realm}-${var.environment}"
#   resource_group_name = var.resource_group_name
#   location            = var.resource_group_location

#   sku {
#     tier = "Standard"
#     size = "S1"
#   }
# }

# resource "azurerm_function_app" "function_app" {
#   name                      = "azure-functions-app-${var.realm}-${var.environment}"
#   resource_group_name       = var.resource_group_name
#   location                  = var.resource_group_location
#   app_service_plan_id       = azurerm_app_service_plan.service_plan.id
#   storage_connection_string = azurerm_storage_account.sapience_functions.primary_connection_string
#   # storage_connection_string = data.terraform_remote_state.storage_account.outputs.primary_connection_string
#   version                   = "~2"
#   app_settings              = {
#     APPINSIGHTS_INSTRUMENTATIONKEY            =  "b3ab9bae-00d2-48a1-865a-b06914e1648f"
#     APPLICATIONINSIGHTS_CONNECTION_STRING     =  "InstrumentationKey=b3ab9bae-00d2-48a1-865a-b06914e1648f"
#     MasterDataConnection                      =  "Server=tcp:sapience-lab-us-demo.database.windows.net,1433;Initial Catalog=mad;Persist Security Info=False;User ID=appsvc_funcapp_user;Password=aPy64NjKCxa418;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
#     ServiceBusConnection                      =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=GTR3qm2mst/Bks8pd8usYdw76baNxXFdUP7TWsu+uaY="
#  }
# }

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
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      Connection                              =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=+wfJ2wzqZ86aeVC3GIhdEOvGgn6Qc1dJFOzWPJdKubg="
      ConnectionString                        =  "Data Source=sapience-lab-us-demo.database.windows.net;Database=Admin;User=appsvc_api_user;Password=kfguJEk29khwkKgi;"  
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "TSACznk8kE9PG6uWFq02zdSN4jB3OpkU"
      Auth0__ManagementApiIdentifier          =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =  "https://sapience-lab-us-demo.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =  "https://sapience-lab-us-demo.auth0.com"
      Auth0__ManagementApiSecret              =  "oJEkTc-Q0TFjqdLsoIxKTmHwW_ohdhPqQy0PCzV27mSvOBWtcBA85BPwaPjJH0I6"
      Sisense__BaseUrl                        =  "https://sisense.demo.lab.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =  "api/users?email="
      Sisense__DefaultGroupUri                =  "api/v1/groups?name="
      Sisense__DataSecurityUri                =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =  "Demo"
      Sisense__Secret                         =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiODNjNmVlNzc5YWYwNTk4YmZiYjg2IiwiYXBpU2VjcmV0IjoiNTZlOTIxZWUtODA4Zi0yZTFkLTYyZWQtYWVjMGU3MTVmMzQ5IiwiaWF0IjoxNTcyMzU1MzExfQ.-K_t519lW-cevSB0V6-PTtLYRlTeBw2mU9l5pL1O7CM"
      Canopy__Auth0Url                        =  "https://api.demo.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =  "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =  "https://api.demo.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=VaCNsnPSvUGW6o2EzxYH8RQxn4TQuZursIVncP3bnOY="
      EditConnection                          =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=UxCI+/JDBtT0rx7jB8af0XLkQRY4J2D0fS+6l7mzekE="
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
      APPINSIGHTS_INSTRUMENTATIONKEY          =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING   =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"  
      Connection                              =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=+wfJ2wzqZ86aeVC3GIhdEOvGgn6Qc1dJFOzWPJdKubg="
      ConnectionString                        =  "Data Source=sapience-lab-us-demo.database.windows.net;Database=Admin;User=appsvc_api_user;Password=kfguJEk29khwkKgi;"  
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "TSACznk8kE9PG6uWFq02zdSN4jB3OpkU"
      Auth0__ManagementApiIdentifier          =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =  "https://sapience-lab-us-demo.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =  "https://sapience-lab-us-demo.auth0.com"
      Auth0__ManagementApiSecret              =  "oJEkTc-Q0TFjqdLsoIxKTmHwW_ohdhPqQy0PCzV27mSvOBWtcBA85BPwaPjJH0I6"
      Sisense__BaseUrl                        =  "https://sisense.demo.lab.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri                       =  "api/users?email="
      Sisense__DefaultGroupUri                =  "api/v1/groups?name="
      Sisense__DataSecurityUri                =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri                 =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource                =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource               =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                            =  "Demo"
      Sisense__Secret                         =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiODNjNmVlNzc5YWYwNTk4YmZiYjg2IiwiYXBpU2VjcmV0IjoiNTZlOTIxZWUtODA4Zi0yZTFkLTYyZWQtYWVjMGU3MTVmMzQ5IiwiaWF0IjoxNTcyMzU1MzExfQ.-K_t519lW-cevSB0V6-PTtLYRlTeBw2mU9l5pL1O7CM"
      Canopy__Auth0Url                        =  "https://api.demo.sapienceanalytics.com/auth0/v1/integrations/auth0"
      Canopy__Credentials                     =  "Sapience:sapience_AdminServices:H#Qx6qbmafdafd112415##!w8#vKKs3"
      Canopy__UserServiceUrl                  =  "https://api.demo.sapienceanalytics.com/user/v1/users/"
      DeleteConnection                        =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=VaCNsnPSvUGW6o2EzxYH8RQxn4TQuZursIVncP3bnOY="
      EditConnection                          =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Full;SharedAccessKey=UxCI+/JDBtT0rx7jB8af0XLkQRY4J2D0fS+6l7mzekE="
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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "b3ab9bae-00d2-48a1-865a-b06914e1648f"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=b3ab9bae-00d2-48a1-865a-b06914e1648f;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      ConnectionString                         =  "Data Source=sapience-lab-us-demo.database.windows.net;Database=Admin;User=appsvc_api_user;Password=kfguJEk29khwkKgi;"  
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
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=KUMb8BU558aN7CcQYyxf0TOkK67brq5dJcijRzwmKq0=;EntityPath=sapience-admin-activity-deleted"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=wHUxWEGiMCl2yjfDvUlhVoXXTauKIVoDUPCs3ob9hQo=;EntityPath=sapience-admin-activity-updated"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=36WX+jAgjf1fqD3R0sDeN6V/Kxitgsu9PQf5iwsk7ZA=;EntityPath=sapience-admin-departments-deleted"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=OdWVu64ZD7HhuJkVXEdtx4uZFZ9zBv1/+XhqRmUfMNY=;EntityPath=sapience-admin-departments-updated"
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
      APPINSIGHTS_INSTRUMENTATIONKEY             =  "b3ab9bae-00d2-48a1-865a-b06914e1648f"
      APPLICATIONINSIGHTS_CONNECTION_STRING      =  "InstrumentationKey=b3ab9bae-00d2-48a1-865a-b06914e1648f;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE            =  true
      WEBSITE_RUN_FROM_PACKAGE                   =  1
      "AzureServiceBus:Endpoint"                 =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=C1jCY7iv2MNAQTyseqdZLeAFNLFILXsapvnNJ4xP7Qc=;"
      "AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      "AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-lab-us-demo.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=C6j0bHH+E1xWeWWekjrbZd7QKFyjHuixO/lu35b2AtQ=;"
      "AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      "IdentityProvider:Issuer"                  =  "https://sapience-lab-us-demo.auth0.com/"
      "IdentityProvider:Audience"                =  "https://api.sapienceanalytics.com"
      "Auth0:Authority"                          =  "https://sapience-lab-us-demo.auth0.com/"
      "Auth0:Audience"                           =  "https://api.sapienceanalytics.com"
      "Auth0:ClientId"                           =  "ot1zP3J0CaNqNcX1EMoy3ob3jLvlTLnc"
      "Auth0:Connection"                         =  "Username-Password-Authentication"
      "Auth0:PingUri"                            =  "https://sapience-lab-us-demo.auth0.com/test"
      "Sisense:BaseUrl"                          =  "https://sapiencebi.demo.lab.us.azure.sapienceanalytics.com/"
      "Sisense:Secret"                           =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWQ5OGNkNWU0MDM2MTcyYjFjYmIxYmViIiwiYXBpU2VjcmV0IjoiZDJlYTM5YWUtY2E2NC0wZGFiLWZhMTUtMmQ3NWEwMjI4NWUxIiwiaWF0IjoxNjExMjEwMjk5fQ.FLEfiUkO_hOc3WdmJeFvUHqMWAzkt7U3EZ0Dho5bkC4"
      "ConnectionStrings:Admin"                  =  "Data Source=sapience-lab-us-demo.database.windows.net;Database=Admin;User=appsvc_api_user;Password=kfguJEk29khwkKgi;"
      "ConnectionStrings:Staging"                =  "Data Source=sapience-lab-us-demo.database.windows.net;Database=Staging;User=appsvc_api_user;Password=kfguJEk29khwkKgi;"
      "UploadBlob:Container"                     =  "sapience-upload"
      "UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=saplabusbudemo;AccountKey=iDtJfg+gPBH2vXbG+5R3ax54kWoon8/KNvX+TXpUpf+GgGZwpmlJuy9gn7th9QeAfSQIMabzHhljejDVatsmYw==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-lab-us-demo:h10lV9LxwJ0RbdGXz43cOQvFrwQ8eY3Yf5RfWGlFwfJOFCkjyd1oR5T9Rd5ZAAV13tWa34C2ZGo3tIBpTtRczg==@sapience-bulk-upload-mongodb-lab-us-demo.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      "BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
      "Integration:ConnString"                   =  "mongodb://sapience-integration-mongodb-lab-us-demo:DlMKzgWRMLZIBLnyj5CvmJwlZw4iFE1Y6OFYVduE6LRYcaUD5Z5fKT370ZnT2WiAtod80gSjVyUojbCVn2mWXA==@sapience-integration-mongodb-lab-us-demo.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-lab-us-demo@"
      "Integration:DatabaseName"                 =  "Test"
      "Integration:Collections:IntegrationEvents" =  "Integration_Events"
  }
}