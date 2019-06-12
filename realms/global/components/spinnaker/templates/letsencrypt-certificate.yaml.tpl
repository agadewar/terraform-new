apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: spinnaker-certs
  namespace: ${namespace}
spec:
  secretName: spinnaker-certs
  issuerRef:
    name: letsencrypt-prod
    kind: Issuer
  # commonName: '*.spinnaker.${realm}.sapience.net'
  commonName: 'spinnaker.${realm}.sapience.net'
  dnsNames:
  - spinnaker.${realm}.sapience.net
  acme:
    config:
    - dns01:
        provider: azure-dns
        ingressClass: nginx
      domains:
      # - '*.spinnaker.${realm}.sapience.net'
      - spinnaker.${realm}.sapience.net