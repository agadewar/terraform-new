resource "kubernetes_ingress" "kibana" {
  metadata {
    name = "kibana"
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
      host = "kibana.prod-us.sapienceanalytics.com"
      http {
        path {
          backend {
            service_name = "efk-kibana"
            service_port = 443
          }

          path = "/"
        }
      }
    }

    tls {
      hosts = [ 
        "kibana.prod-us.sapienceanalytics.com",
      ]
      secret_name = "kibana-ui-certs"
    }
  }
}

