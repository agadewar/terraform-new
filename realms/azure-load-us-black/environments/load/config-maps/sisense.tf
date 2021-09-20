resource "kubernetes_config_map" "sisense" {
  metadata {
    name      = "sisense"
    namespace = local.namespace
  }

  data = {
      #SISENSE ENVIRONMENT
      "Sisense__Env" = "Load"

#SISENSE DATASOURCES
      #"Sisense__DataSource"       = "Set/Sapience-Daily-CompanyId-Env"
      "Sisense__DataSource"        = "Sapience-Daily-CompanyId-Env"
      "Sisense_DailyDataSource"    = "Sapience-Daily-CompanyId-Env"
      "Sisense_HourlyDataSource"   = "Sapience-Hourly-CompanyId-Env"

      #SISENSE URIs
      "Sisense__AuthUri"           = "api/v1/authentication/login" 
      "Sisense_DataSecurityUri"    = "api/elasticubes/datasecurity"
      "Sisense_DefaultGroupUri"    = "api/v1/groups?name=Employee"
      "Sisense_DeleteUserUri"      = "api/v1/users/"
      "Sisense_ElasticubesUri"     = "api/v1/elasticubes/getElasticubes"
      "Sisense_PingUri"            = "api/test"
      
      #UPDATE REQUEST URI (e.g. SapienceCube-[Env])
      "Sisense__RequestUri"        = "api/datasources/SapienceCube-Dev/jaql"
      "Sisense_SearchUserUri"      = "api/users?search="
      "Sisense_SecurityUri"        = "api/settings/security"
      "Sisense_UsersUri"           = "api/users?notify=false"

      #SISENSE EXTERNAL ENDPOINTS
      #"ENVIRONMENT_SISENSE_URL"          = "https://sisense-linux.load.sapienceanalytics.com"
      "ENVIRONMENT_SISENSE_URL"          = "https://sapiencebi.load.sapienceanalytics.com"
      "ENVIRONMENT_SISENSE_JS_PLATFORM"  =  "linux"

      #SISENSE INTERNAL ENDPOINTS
      # "Sisense__BaseHost"             = "https://sisense-linux.load.sapienceanalytics.com/"
      # "Sisense__SecurityEndpoint"     = "https://sisense-linux.load.sapienceanalytics.com/api/settings/security"
      # "Sisense__UserSecurityEndpoint" = "https://sisense-linux.load.sapienceanalytics.com/api/v1/users"
      # "Sisense__BaseUrl"              = "https://sisense-linux.load.sapienceanalytics.com/"

      "Sisense__BaseHost"             = "https://sapiencebi.load.sapienceanalytics.com/"
      "Sisense__SecurityEndpoint"     = "https://sapiencebi.load.sapienceanalytics.com/api/settings/security"
      "Sisense__UserSecurityEndpoint" = "https://sapiencebi.load.sapienceanalytics.com/api/v1/users"
      "Sisense__BaseUrl"              = "https://sapiencebi.load.sapienceanalytics.com/"
  }
  }
