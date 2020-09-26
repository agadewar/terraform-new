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
              
additionalPrometheusRules:
  - name: custom-rules-file
    groups:
      - name: custom-node-exporter-rules
        rules:
          - alert: PhysicalComponentTooHot
            expr: node_hwmon_temp_celsius > 75
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Physical component too hot (instance {{ $labels.instance }})"
              description: "Physical hardware component too hot\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: NodeOvertemperatureAlarm
            expr: node_hwmon_temp_alarm == 1
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Node overtemperature alarm (instance {{ $labels.instance }})"
              description: "Physical node temperature alarm triggered\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

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
    size: 50Gi