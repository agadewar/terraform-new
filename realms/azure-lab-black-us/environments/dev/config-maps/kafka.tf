resource "kubernetes_config_map" "kafka" {
  metadata {
    name      = "kafka"
    namespace = local.namespace
  }

  data = {
    "ssl_endpoint_identification_algorithm" = "https"
    "sasl_mechanism" = "PLAIN"
    "request_timeout_ms" = 20000
    "bootstrap_servers" = var.kafka_bootstrap_servers
    "retry_backoff_ms" = 500
    "sasl_jaas_config" = "org.apache.kafka.common.security.plain.PlainLoginModule required username=\"${KAFKA_USERNAME}\" password=\"${KAFKA_PASSWORD}\";"
    "security_protocol" = "SASL_SSL"
  }
}
