resource "kubernetes_ingress" "grafana" {
  metadata {
    name = "grafana"
    namespace = local.namespace

    annotations = {
      "cert-manager.io/cluster-issuer"                  = "letsencrypt-prod"
      "kubernetes.io/ingress.class"                        = "nginx"
      "kubernetes.io/tls-acme"                             = "true"
      "ingress.kubernetes.io/ssl-redirect"           = "true"
      "nginx.ingress.kubernetes.io/whitelist-source-range" = "219.91.160.58/32,47.190.73.52/32"
    }
  }

  spec {
    rule {
      host = "monitoring.lab-black.sapienceanalytics.com"
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
        "monitoring.lab-black.sapienceanalytics.com",
      ]
      secret_name = "grafana-ui-certs"
    }
  }
}
