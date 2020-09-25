# Depending on which DNS solution you have installed in your cluster enable the right exporter
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: alertmanager-lab-red-us
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.109.196.4
    path: 10.109.196.4:/alertmanager-lab-red-us


apiVersion: v1
kind: PersistentVolume
metadata:
  name: grafana-lab-red-us
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.109.196.4
    path: 10.109.196.4:/grafana-lab-us-red


apiVersion: v1
kind: PersistentVolume
metadata:
  name: prometheus-lab-us-red
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: 10.109.196.4
    path: 10.109.196.4:/prometheus-lab-us-red

coreDns:
  enabled: false

kubeDns:
  enabled: true

alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
            volumeMounts:
              - name: alertmanager-lab-red-us
                mountPath: 10.109.196.4:/alertmanager-lab-red-us
prometheus:
  storage:
      volumeClaimTemplate:
        spec:
          volumeMounts:
            - name: prometheus-lab-us-red
              mountPath: 10.109.196.4:/prometheus-lab-us-red

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
  image:
    repository: grafana/grafana
    tag: 6.7.3
    sha: ""
    pullPolicy: IfNotPresent
  storage:
      volumeClaimTemplate:
        spec:
          volumeMounts:
            - name: grafana-lab-us-red
              mountPath: 10.109.196.4:/grafana-lab-us-red
