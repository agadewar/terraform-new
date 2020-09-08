resource "kubernetes_secret" "redis-dashboard" {
  metadata {
    name = "redis-dashboard"
    namespace = local.namespace
  }

  data = {
      RedisCacheSettings__Endpoint__Password   =   var.redis_dashboard_Password
  }
}