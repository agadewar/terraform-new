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
              storage: 10Gi

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
    size: 50Gi