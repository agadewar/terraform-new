apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: ambassador-certs
  namespace: ${environment}
spec:
  secretName: ambassador-certs
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
  - api.${environment}.${realm}.sapienceanalytics.com
  - api.${environment}.sapienceanalytics.com
  acme:
    config:
    - dns01:
        provider: azure-dns
        ingressClass: nginx
      domains:
      - api.${environment}.${realm}.sapienceanalytics.com
      - api.${environment}.sapienceanalytics.com
