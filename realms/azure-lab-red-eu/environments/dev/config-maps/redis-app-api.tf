resource "kubernetes_config_map" "redis-app-api" {
  metadata {
    name      = "redis-app-api"
    namespace = local.namespace
  }

  data = {
      "RedisCacheSettings__Endpoint__server"       =     "sapience-redis-cache-lab-eu-dev.redis.cache.windows.net"
      "RedisCacheSettings__Endpoint__SSL"          =     "true"
      "RedisCacheSettings__Endpoint__Port"         =     "6380"
      "RedisCacheSettings__DefaultDatabase"         =     "1"
      "RedisCacheSettings__Enabled"                =     "true"
      "RedisCacheSettings__ConnectRetry"           =     "3"
      "RedisCacheSettings__TTL"                    =     "21600"
      "RedisCacheSettings__ConnectTimeout"         =     "100000"
}
}