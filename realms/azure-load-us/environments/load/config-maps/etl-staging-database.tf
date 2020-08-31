resource "kubernetes_config_map" "etl_staging_database" {
  metadata {
    name      = "etl-staging-database"
    namespace = local.namespace
  }

  data = {
      "KAFKA_BOOTSTRAP_SERVERS": "sapience-eventhub-load-us-load.servicebus.windows.net:9093"
      "KAFKA_CLUSTER_API_KEY": "$ConnectionString"
      "KAFKA_GROUP_ID": "etl-staging-database"
      "KAFKA_MAX_POLL_RECORDS": "500"
      "KAFKA_RETRY_BACKOFF_MS": "500"
      "KAFKA_TOPIC": "canopy-eventpipeline"
      "MAX_SLEEP_MS_ON_EMPTY_POLL": "3000"
      "MIN_SLEEP_MS_ON_EMPTY_POLL": "100"
      "STAGING_DATABASE_NAME": "Staging"
      "STAGING_DATABASE_PORT": "1433"
      "STAGING_DATABASE_SERVER_NAME": "sapience-load-us-load.database.windows.net"
      "STAGING_DATABASE_USERNAME": "appsvc_etl_user"
      "THREAD_POOL_SIZE": "10"
  }
}