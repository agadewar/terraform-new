# Depending on which DNS solution you have installed in your cluster enable the right exporter
coreDns:
  enabled: false

kubeDns:
  enabled: true

alertmanager:
  config:
    global:
      resolve_timeout: 5m
    receivers:
    - name: eks_alerts
      opsgenie_configs:
      - api_key: ${api_key}
    route:
      group_by:
      - job
      group_interval: 5m
      group_wait: 30s
      receiver: eks_alerts
      repeat_interval: 12h
      routes:
      - match:
          alertname: Watchdog
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 100Gi

grafana:
  adminPassword: ${admin_password}
  image:
    repository: grafana/grafana
    tag: 6.7.3
    sha: ""
    pullPolicy: IfNotPresent
    
#   ingress:
#     enabled: true
#     # annotations:
#     #   kubernetes.io/ingress.class: nginx
#     #   kubernetes.io/tls-acme: "true"
#     # hosts:
#     #   - grafana.test.akomljen.com
#     # tls:
#     #   - secretName: grafana-tls
#     #     hosts:
#     #       - grafana.test.akomljen.com
  persistence:
    enabled: true
    accessModes: ["ReadWriteOnce"]
    size: 100Gi
  grafana.ini:
    auth.azuread:
      name: Azure AD
      enabled: true
      allow_sign_up: true
      client_id: 14314a12-8baf-413e-a3cf-d7a57acc20ec
      client_secret: ~gEZPm5Z2ap35TN-O.jWOr~~Kx3sUX9e76
      scopes: openid email profile
      auth_url: https://login.microsoftonline.com/9c5c9da2-8ba9-4f91-8fa6-2c4382395477/oauth2/v2.0/authorize
      token_url: https://login.microsoftonline.com/9c5c9da2-8ba9-4f91-8fa6-2c4382395477/oauth2/v2.0/token
    server:
      domain: monitoring.prod-us.sapienceanalytics.com
      enforce_domain: false
      serve_from_sub_path: false
      root_url: https://monitoring.prod-us.sapienceanalytics.com

