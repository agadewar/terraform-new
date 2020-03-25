ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    ingress.kubernetes.io/ssl-redirect: true
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: true
  tls:
    - hosts:
        - openfaas.${environment}.${dns_realm}-black.${region}.${cloud}.sapienceanalytics.com
        - openfaas.${environment}.${dns_realm}.${region}.${cloud}.sapienceanalytics.com
        - openfaas.${environment}.sapienceanalytics.com
      secretName: openfaas-certs
  hosts:
    - host: openfaas.${environment}.${dns_realm}-black.${region}.${cloud}.sapienceanalytics.com
      serviceName: gateway
      servicePort: 8080
      path: /
    - host: openfaas.${environment}.${dns_realm}.${region}.${cloud}.sapienceanalytics.com
      serviceName: gateway
      servicePort: 8080
      path: /
    - host: openfaas.${environment}.sapienceanalytics.com
      serviceName: gateway
      servicePort: 8080
      path: /
