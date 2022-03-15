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
  account_kind             = "Storage"
  account_replication_type = "GRS"
  enable_https_traffic_only = false

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
    tier = "Free"
    size = "F1"
  }
}


resource "azurerm_storage_account" "sapience_functions_admin_users" {
  name                     = "adminfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"
  enable_https_traffic_only = false

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
      Sisense__BaseUrl                =  "https://sapiencebi.qa.lab.us.azure.sapienceanalytics.com/"
      Sisense__UsersUri               =  "api/v1/users/bulk"
      "Sisense__Server"               = "localhost"
      "Sisense__OperatingSystem"      = "linux"
      Sisense__DefaultGroupUri        =  "api/v1/groups?name="
      Sisense__DataSecurityUri        =  "api/elasticubes/datasecurity"
      Sisense__ElasticubesUri         =  "api/v1/elasticubes/getElasticubes"
      Sisense__DailyDataSource        =  "Sapience-Daily-CompanyId-Env"
      Sisense__HourlyDataSource       =  "Sapience-Hourly-CompanyId-Env"
      Sisense__Env                    =  "QA"
      "Sisense__Secret"               = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiMTQwZTU2ZDY4MWQyMjQwYjhjYTk0IiwiYXBpU2VjcmV0IjoiMzBhMDNlZGUtZDU4OS0zMzcxLWYxZjktMDMyZjBiZGQ2MzdkIiwiaWF0IjoxNjEwNzM4NTkyfQ.0x_1JTaZcm7Re4OIavzr3NpUlGdbAtpzgajtX-qh45I"
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
      "TeamCreatedConnection"         = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=q5vdV9yCTreXg5hYP0RWcUbfNQelIis0p+pePIal/hA=;"
      "TeamDeletedConnection"         = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=jkqxs5mcFgkZRxMVVl8ii2uI9IKahNXlQ5nQIOMKxLo=;"
      "TeamUpdatedConnection"         = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=IfuXxepryD0dmazzBhkWZQyuwvGp/8aJFBSJ1QxTyzs=;"
      "UserActivatedConnection"       = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=3XjJIoBhfDSc0c7UPlklBCmo5iA9WTEKFxrMcPjeSd0=;"
      "UserDeactivatedConnection"     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=RlmclTYHC1o3mlcmJF7M7R/7/SaaKmex9G61MJ8fOr4=;"


  }
}

resource "azurerm_function_app" "bulk_upload" {
  name                      = "azure-admin-bulk-upload-${var.realm}-${var.environment}"
  resource_group_name       = var.resource_group_name
  location                  = var.resource_group_location
  app_service_plan_id       = azurerm_app_service_plan.service_bulk_upload_plan_admin_users.id
  storage_connection_string = azurerm_storage_account.sapience_bulk_upload_admin_users_fn.primary_connection_string
  version                   = "3.1"
  app_settings                             = {
      APPINSIGHTS_INSTRUMENTATIONKEY                 =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING          =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE                =  true
      WEBSITE_RUN_FROM_PACKAGE                       =  1
      "AzureServiceBus__Endpoint"                    =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=x9D7XYbxSiMMVssulaXMBn4Q12u7SEHX1pqAkAToGJQ=;"
      "AzureServiceBus__EntityPath"                  =  "sapience-admin-users-created"
      "AzureServiceBus__DeletedUsersEndPoint"        =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=JzwF1gV5j3J19tXwUFR94d9UFu3Nw+8R5nJu6w1XywI="
      "AzureServiceBus__DeletedUsersEntityPath"      =  "sapience-admin-users-deleted"
      "IdentityProvider__Issuer"                     =  "https://login.qa.lab.sapienceanalytics.com/"
      "IdentityProvider__Audience"                   =  "https://api.sapienceanalytics.com"
      "Authorization__Auth0__Authority"              =  "https://login.qa.lab.sapienceanalytics.com/"
      "Authorization__Auth0__Audience"               =  "https://api.sapienceanalytics.com"
      "Authorization__Auth0__ClientId"               =  "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "Authorization__Auth0__Connection"             =  "Username-Password-Authentication"
      "Authorization__Auth0__PingUri"                =  "https://login-qa-lab-sapienceanalytics.com/test"
      "Sisense__BaseUrl"                             =  "https://sapiencebi-qa-lab-us-azure.sapienceanalytics.com/"
      "Sisense__Secret"                              =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiMTQwZTU2ZDY4MWQyMjQwYjhjYTk0IiwiYXBpU2VjcmV0IjoiMzBhMDNlZGUtZDU4OS0zMzcxLWYxZjktMDMyZjBiZGQ2MzdkIiwiaWF0IjoxNjEwNzM4NTkyfQ.0x_1JTaZcm7Re4OIavzr3NpUlGdbAtpzgajtX-qh45I"
      "ConnectionStrings__Admin"                     =  "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"
      "ConnectionStrings__Staging"                   =  "Data Source=sapience-lab-us-qa.database.windows.net;Database=Staging;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"
      "UploadBlob__Container"                        =  "sapience-upload"
      "UploadBlob__StorageAccountAccessKey"          =  "DefaultEndpointsProtocol=https;AccountName=saplabusbuqa;AccountKey=q7grbVonfNFUL7HSHNIgwtJjz/KIRCyBeH8SKeO+Q0zC+YykISAOwG3/+h6OyAtcbVe4Tf2pAnfUVqM9+IAwfQ==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig__ConnString"               =  "mongodb://sapience-bulk-upload-mongodb-lab-us-qa:kwsQHEgniw6IaD3MbUrBDdY82TYCEpeFeB7jJP4h2mDHNpPrrCyqVBzcBn6Nz9a5KXmh0fx8rw7Hs0TWRm7YRg==@sapience-bulk-upload-mongodb-lab-us-qa.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig__DatabaseName"             =  "BulkUploadWorkflow"
      "BulkUploadDbConfig__Events"                   =  "BulkUploadEvents"
      "Integration__ConnString"                      =  "mongodb://sapience-integration-mongodb-lab-us-qa:AHy4LBIBvwdgxC0czSq9iM4xjsBaLbbjbtocBsMOWpemUb9yv4SuANv3kJVahmPrZmbxfN3N9ihkPATkNkju9g==@sapience-integration-mongodb-lab-us-qa.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-lab-us-qa@"
      "Integration__DatabaseName"                    =  "Test"
      "Integration__Collections__IntegrationEvents"  =  "Integration_Events"
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

resource "azurerm_storage_account" "sapience_bulk_upload_admin_users" {
  name                     = "adminfn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"
  enable_https_traffic_only = false

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
  account_kind             = "Storage"
  account_replication_type = "GRS"
  enable_https_traffic_only = false

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
      "ConnectionString"                      =  "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_tenant_user;Password=3tRdz8xPSz3ZVB;" 
      FUNCTIONS_WORKER_RUNTIME                =  "dotnet"
      Auth0__Connection                       =  "Username-Password-Authentication"
      Auth0__ManagementApiClientId            =  "0ljzI5jQnH9Fx8yQLxWxGdYOVQGRB4DY"
      Auth0__ManagementApiIdentifier          =  "https://api.sapienceanalytics.com"
      Auth0__ManagementApiAudience            =  "https://qa-sapienceanalytics.auth0.com/api/v2/"
      Auth0__ManagementApiBaseUrl             =  "https://qa-sapienceanalytics.auth0.com"
      Auth0__ManagementApiSecret              =  "KQiCawIg9O6LzN7r-ABbvq4kkaE0WfosK6nBhkW9uAwx5_lpe8BsB2HtTZMqE0Ka"
      Sisense__BaseUrl                        =  "https://sapiencebi.qa.lab.us.azure.sapienceanalytics.com/"
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
  enable_https_traffic_only = false

  tags = merge(local.common_tags, {})
}

resource "azurerm_storage_account" "sapience_functions_notifications" {
  name                     = "sapiencenotifn${replace(lower(var.realm), "-", "")}${var.environment}"
  resource_group_name      = var.resource_group_name
  location                 = "eastus2"
  account_tier             = "Standard"
  account_kind             = "Storage"
  account_replication_type = "GRS"
  enable_https_traffic_only = false

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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  "true"
      WEBSITE_RUN_FROM_PACKAGE                 =  "1"      
      "ActivityDeletedConnection"              = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=gccGmPC1aAPyc+SdHK7OyGjxQSVuCodwV+blcB7if28=;"
      "ActivityUpdatedConnection"              = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=jxi0cU8bRkaWZvA34u/4b+r89PnJ/CAGJh/vJMOD/Ek=;"
      "DepartmentDeletedConnection"            = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=BGv2X/45vAWiqrOv7g5zJ96SvqdujcsdOSOLn+TVpTE=;"
      "DepartmentUpdatedConnection"            = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=SUI+iQWMS5JRwl+f53agq00aML2RBun0HCrmXCpLvJE=;"
  }
}

resource "azurerm_storage_account" "sapience_functions_admin_int_api" {
  name                     = "sapadminintapifn${replace(lower(var.realm), "-", "")}${var.environment}"
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
      APPINSIGHTS_INSTRUMENTATIONKEY           =  "7d7584bc-a5f2-42b1-a4d1-ef786665144b"
      APPLICATIONINSIGHTS_CONNECTION_STRING    =  "InstrumentationKey=7d7584bc-a5f2-42b1-a4d1-ef786665144b;IngestionEndpoint=https://eastus-1.in.applicationinsights.azure.com/"
      WEBSITE_ENABLE_SYNC_UPDATE_SITE          =  true
      WEBSITE_RUN_FROM_PACKAGE                 =  1
      "AzureServiceBus:Endpoint"                 =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=x9D7XYbxSiMMVssulaXMBn4Q12u7SEHX1pqAkAToGJQ=;"
      "AzureServiceBus:EntityPath"               =  "sapience-admin-users-created"
      "AzureServiceBus:DeletedUsersEndPoint"     =  "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=JzwF1gV5j3J19tXwUFR94d9UFu3Nw+8R5nJu6w1XywI="
      "AzureServiceBus:DeletedUsersEntityPath"   =  "sapience-admin-users-deleted"
      "IdentityProvider:Issuer"                  =  "https://login.qa.lab.sapienceanalytics.com/"
      "IdentityProvider:Audience"                =  "https://api.sapienceanalytics.com"
      "Auth0:Authority"                          =  "https://login.qa.lab.sapienceanalytics.com/"
      "Auth0:Audience"                           =  "https://api.sapienceanalytics.com"
      "Auth0:ClientId"                           =  "ZxBrWiPNzzpjMA2zJep8BxLz9zQCmWDo"
      "Auth0:Connection"                         =  "Username-Password-Authentication"
      "Auth0:PingUri"                            =  "https://login.qa.lab.sapienceanalytics.com/test"
      "Sisense:BaseUrl"                          =  "https://sapiencebi.qa.lab.us.azure.sapienceanalytics.com/"
      "Sisense:Secret"                           =  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNWRiMTQwZTU2ZDY4MWQyMjQwYjhjYTk0IiwiYXBpU2VjcmV0IjoiMzBhMDNlZGUtZDU4OS0zMzcxLWYxZjktMDMyZjBiZGQ2MzdkIiwiaWF0IjoxNjEwNzM4NTkyfQ.0x_1JTaZcm7Re4OIavzr3NpUlGdbAtpzgajtX-qh45I"
      "ConnectionStrings:Admin"                  =  "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"
      "ConnectionStrings:Staging"                = "Data Source=sapience-lab-us-qa.database.windows.net;Database=Staging;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"
      "UploadBlob:Container"                     = "sapience-upload"
      "UploadBlob:StorageAccountAccessKey"       =  "DefaultEndpointsProtocol=https;AccountName=saplabusbuqa;AccountKey=q7grbVonfNFUL7HSHNIgwtJjz/KIRCyBeH8SKeO+Q0zC+YykISAOwG3/+h6OyAtcbVe4Tf2pAnfUVqM9+IAwfQ==;EndpointSuffix=core.windows.net"
      "BulkUploadDbConfig:ConnString"            =  "mongodb://sapience-bulk-upload-mongodb-lab-us-qa:kwsQHEgniw6IaD3MbUrBDdY82TYCEpeFeB7jJP4h2mDHNpPrrCyqVBzcBn6Nz9a5KXmh0fx8rw7Hs0TWRm7YRg==@sapience-bulk-upload-mongodb-lab-us-qa.documents.azure.com:10255/?ssl=true&replicaSet=globaldb"
      "BulkUploadDbConfig:DatabaseName"          =  "BulkUploadWorkflow"
      "BulkUploadDbConfig:Events"                =  "BulkUploadEvents"
      "Integration:ConnString"                   =  "mongodb://sapience-integration-mongodb-lab-us-qa:AHy4LBIBvwdgxC0czSq9iM4xjsBaLbbjbtocBsMOWpemUb9yv4SuANv3kJVahmPrZmbxfN3N9ihkPATkNkju9g==@sapience-integration-mongodb-lab-us-qa.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-lab-us-qa@"
      "Integration:DatabaseName"                 =  "Test"
      "Integration:Collections:IntegrationEvents" =  "Integration_Events"
  }
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
  name                = "azure-functions-app-sapience-admin-core-${var.realm}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  app_service_plan_id = azurerm_app_service_plan.service_plan_admin_core.id
  #app_settings               = var.function_app_admin_users  
  storage_connection_string = azurerm_storage_account.sapience_functions_admin_core.primary_connection_string
  version                   = "5.0"

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME                 = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE          = true
    WEBSITE_RUN_FROM_PACKAGE                 = 1
    Connection                               = "Endpoint=sb://sapience-${var.realm}-${var.environment}.servicebus.windows.net/;SharedAccessKeyName=Subscribe;SharedAccessKey=/PWQZJwtG9LOKdJG0xK1hHucIgB24GDqlj5nuWIuyNw="
    FUNCTIONS_WORKER_RUNTIME                 = "dotnet"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE          = true
    WEBSITE_RUN_FROM_PACKAGE                 = 1
    AzureServiceBus__UserCreatedEndpoint     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=x9D7XYbxSiMMVssulaXMBn4Q12u7SEHX1pqAkAToGJQ=;"
    AzureServiceBus__UserDeletedEndpoint     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=JzwF1gV5j3J19tXwUFR94d9UFu3Nw+8R5nJu6w1XywI=;"
    AzureServiceBus__UserUpdatedEndpoint     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=+Eroe177bx7QH4Rxa27w/4JcQz+V/MQoioODtdYYR3Q=;"
    AzureServiceBus__UserActivatedEndpoint   = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=gVRdguOg57vdiENhEJtGtCmplyofHajJE4Le+wIxzMc=;"
    AzureServiceBus__UserDeactivatedEndpoint = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=8dLg1rD+Wef/yCBEv0iMMCnXdoL+Rbd1+rPfrbiW/A8=;"
    AzureServiceBus__TeamCreatedEndpoint     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=9dul+PfKkRmhv4lCUArkN99RfmSYEON28DAL+tQ6Kcs=;"
    AzureServiceBus__TeamDeletedEndpoint     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=EIlG8bZWeJ/ypzFmMJ+wPElD/iiLx5bJN6hfBqAmzYU=;"
    AzureServiceBus__TeamUpdatedEndpoint     = "Endpoint=sb://sapience-lab-us-qa.servicebus.windows.net/;SharedAccessKeyName=Publish;SharedAccessKey=OLmzMRHwkQuX0UkeiwTD3GkvOYp4VxlR3Oc47GQFw4g=;"
    ConnectionStrings__Admin                 = "Data Source=sapience-lab-us-qa.database.windows.net;Database=Admin;User=appsvc_api_user;Password=T9TbZHe8BnoZapR4JRkU;"
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