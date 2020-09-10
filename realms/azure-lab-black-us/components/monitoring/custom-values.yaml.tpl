# Depending on which DNS solution you have installed in your cluster enable the right exporter
coreDns:
  enabled: false

kubeDns:
  enabled: true

alertmanager:
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi

alertmanagerFiles:
  alertmanager.yml: |-
    global:
      resolve_timeout: 5m
      # slack_api_url: ''
    receivers:
      - name: eks_alerts
        opsgenie_configs:
        - api_key: 1cefb4a0-890c-46d7-b596-1fc19ff4f324
    route:
      group_wait: 30s
      group_interval: 5m
      receiver: eks_alerts
      repeat_interval

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
    size: 10Gi