apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: ambassador-certs
  namespace: ${namespace}
spec:
  secretName: ambassador-certs
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  #commonName: '*.api.${namespace}.sapience.net'
  commonName: 'api.${namespace}.sapience.net'
  dnsNames:
  - api.${namespace}.sapience.net
  acme:
    config:
    - dns01:
        provider: azure-dns
        ingressClass: nginx
      domains:
      #- '*.api.${namespace}.sapience.net'
      - api.${namespace}.sapience.net