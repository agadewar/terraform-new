resource "kubernetes_config_map" "redis-dashboard" {
  metadata {
    name      = "redis-dashboard"
    namespace = local.namespace
  }

  data = {
      "RedisCacheSettings__Endpoint__server"       =     "sapience-redis-cache-lab-us-demo.redis.cache.windows.net"
      "RedisCacheSettings__Endpoint__SSL"          =     "true"
      "RedisCacheSettings__Endpoint__Port"         =     "6380"
      "RedisCacheSetting__DefaultDatabase"         =     "0"
      "RedisCacheSettings__Enabled"                =     "true"
      "RedisCacheSettings__ConnectRetry"           =     "3"
      "RedisCacheSettings__TTL"                    =     "21600"
      "RedisCacheSettings__ConnectTimeout"         =     "100000"

}
}