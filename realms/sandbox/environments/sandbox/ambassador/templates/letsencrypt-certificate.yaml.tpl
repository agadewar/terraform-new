apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: ambassador-certs
  namespace: ${environment}
spec:
  secretName: ambassador-certs
  issuerRef:
    name: letsencrypt-prod
    kind: Issuer
  dnsNames:
  - api.${environment}.${realm}.sapience.net
  - api.${environment}.sapience.net
  acme:
    config:
    - dns01:
        provider: azure-dns
        ingressClass: nginx
      domains:
      - api.${environment}.${realm}.sapience.net
      - api.${environment}.sapience.net