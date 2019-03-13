---
apiVersion: v1
kind: Service
metadata:
  name: acme-challenge-service
  annotations:
    getambassador.io/config: |
      ---
      apiVersion: ambassador/v1
      kind:  Mapping
      name:  acme-challenge-mapping
      prefix: /.well-known/acme-challenge
      rewrite: ""
      service: acme-challenge-service 
spec:
  ports:
  - port: 80
    targetPort: 8089
  selector:
    certmanager.k8s.io/acme-http-domain: "${acme_http_domain}"
    certmanager.k8s.io/acme-http-token: "${acme_http_token}"   