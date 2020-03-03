resource "kubernetes_config_map" "sisense" {
  metadata {
    name      = "sisense"
    namespace = local.namespace
  }

  data = {
      #SISENSE ENVIRONMENT
      "Sisense__Env" = "QA"

      #SISENSE DATASOURCES
      "Sisense__DataSource" = "Sapience-Daily-CompanyId-Env"
      "Sisense_DailyDataSource" = "Sapience-Daily-CompanyId-Env"
      "Sisense_HourlyDataSource" = "Sapience-Hourly-CompanyId-Env"

      #SISENSE URIs
      "Sisense__AuthUri" = "api/v1/authentication/login" 
      "Sisense_DataSecurityUri" = "api/elasticubes/datasecurity"
      "Sisense_DefaultGroupUri" = "api/v1/groups?name=Employee"
      "Sisense_DeleteUserUri" = "api/v1/users/"
      "Sisense_ElasticubesUri" = "api/v1/elasticubes/getElasticubes"
      "Sisense_PingUri" = "api/test"
      "Sisense__RequestUri" = "api/elasticubes/SapienceCube-QA/jaql"
      "Sisense_SearchUserUri" = "api/users?search="
      "Sisense_SecurityUri" = "api/settings/security"
      "Sisense_UsersUri" = "api/users?notify=false"

      #SISENSE EXTERNAL ENDPOINTS
      "ENVIRONMENT_SISENSE_URL" = "https://sisense.qa.lab.us.azure.sapienceanalytics.com"

      #SISENSE INTERNAL ENDPOINTS
      "Sisense__BaseHost" = "http://sisense.qa.lab.us.azure.internal.sapienceanalytics.com:8081/"
      "Sisense__SecurityEndpoint" = "http://sisense.qa.lab.us.azure.internal.sapienceanalytics.com:8081/api/settings/security"
      "Sisense__UserSecurityEndpoint" = "http://sisense.qa.lab.us.azure.internal.sapienceanalytics.com:8081/api/v1/users"
  }
}