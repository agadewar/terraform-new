---
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
  dnsNames:
  - api.${namespace}.sapience.net
  acme:
    config:
    - http01:
        ingressClass: nginx
      domains:
      - api.${namespace}.sapience.net