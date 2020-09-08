resource "kubernetes_config_map" "redis-alerts-api" {
  metadata {
    name      = "redis-alerts-api"
    namespace = local.namespace
  }

  data = {
      "RedisCacheSettings__Endpoint__server"       =     "sapience-redis-cache-lab-us-qa.redis.cache.windows.net"
      "RedisCacheSettings__Endpoint__SSL"          =     "true"
      "RedisCacheSettings__Endpoint__Port"         =     "6380"
      "RedisCacheSettings__DefaultDatabase"         =     "2"
      "RedisCacheSettings__Enabled"                =     "true"
      "RedisCacheSettings__ConnectRetry"           =     "3"
      "RedisCacheSettings__TTL"                    =     "14400"
      "RedisCacheSettings__ConnectTimeout"         =     "100000"
}
}