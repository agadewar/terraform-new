resource "kubernetes_ingress" "grafana" {
  metadata {
    name = "grafana"
    namespace = local.namespace

    annotations = {
      "cert-manager.io/cluster-issuer"                  = "letsencrypt-prod"
      "kubernetes.io/ingress.class"                        = "nginx"
      "kubernetes.io/tls-acme"                             = "true"
      "ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "114.143.13.42/32,47.190.73.52/32"
    }
  }

  spec {
    rule {
      host = "monitoring.prod-us.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "prometheus-grafana"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [ 
        "monitoring.prod-us.sapienceanalytics.com",
      ]
      secret_name = "grafana-ui-certs"
    }
  }
}
