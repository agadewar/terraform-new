resource "kubernetes_config_map" "databases" {
  metadata {
    name      = "databases"
    namespace = local.namespace
  }

  data = {
      "sql_server_name"                  = "sapience-lab-us-qa.database.windows.net"
      "data_warehouse"                   = "edw"
      "api_service_account"              = "appsvc_api_user"
      "machine_learning_service_account" = "appsvc_ml_user"
      "MongoDBConnectorSettings__ServerName"           = "sapience-integration-mongodb-lab-us-qa.mongo.cosmos.azure.com"
      "MongoDBConnectorSettings__ConnectionProperties" = "ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@sapience-integration-mongodb-lab-us-qa@"
      "MongoDBConnectorSettings__UserName"             = "sapience-integration-mongodb-lab-us-qa"
  }
}
