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

additionalPrometheusRules:
  - name: custom-rules-file
    groups:
      - name: custom-kubernetes-monitoring-rules
        rules:
          - alert: KubernetesNodeOutOfDisk
            expr: kube_node_status_condition{condition="OutOfDisk",status="true"} == 1
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes Node out of disk (instance {{ $labels.instance }})"
              description: "{{ $labels.node }} has OutOfDisk condition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesCronjobSuspended
            expr: kube_cronjob_spec_suspend != 0
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Kubernetes CronJob suspended (instance {{ $labels.instance }})"
              description: "CronJob {{ $labels.namespace }}/{{ $labels.cronjob }} is suspended\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesPersistentvolumeclaimPending
            expr: kube_persistentvolumeclaim_status_phase{phase="Pending"} == 1
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Kubernetes PersistentVolumeClaim pending (instance {{ $labels.instance }})"
              description: "PersistentVolumeClaim {{ $labels.namespace }}/{{ $labels.persistentvolumeclaim }} is pending\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesPersistentvolumeError
            expr: kube_persistentvolume_status_phase{phase=~"Failed|Pending",job="kube-state-metrics"} > 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes PersistentVolume error (instance {{ $labels.instance }})"
              description: "Persistent volume is in bad state\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesStatefulsetDown
            expr: (kube_statefulset_status_replicas_ready / kube_statefulset_status_replicas_current) != 1
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes StatefulSet down (instance {{ $labels.instance }})"
              description: "A StatefulSet went down\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesPodNotHealthy
            expr: min_over_time(sum by (namespace, pod) (kube_pod_status_phase{phase=~"Pending|Unknown|Failed|ErrImagePull|ImagePullBackOff"})[1h:]) > 0
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes Pod not healthy (instance {{ $labels.instance }})"
              description: "Pod has been in a non-ready state for longer than an hour.\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesHpaScalingAbility
            expr: kube_hpa_status_condition{condition="false", status="AbleToScale"} == 1
            for: 5m
            labels:
              severity: warning
            annotations:
              summary: "Kubernetes HPA scaling ability (instance {{ $labels.instance }})"
              description: "Pod is unable to scale\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesNodeMemoryPressure
            expr: kube_node_status_condition{condition="MemoryPressure",status="true"} == 1
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes Node memory pressure (instance {{ $labels.instance }})"
              description: "{{ $labels.node }} has MemoryPressure condition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesNodeDiskPressure
            expr: kube_node_status_condition{condition="DiskPressure",status="true"} == 1
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes Node disk pressure (instance {{ $labels.instance }})"
              description: "{{ $labels.node }} has DiskPressure condition\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
          - alert: KubernetesPodResourcesCPULimits
            expr: sum by (namespace, pod) (node_namespace_pod_container:container_cpu_usage_seconds_total:sum_rate) > ((sum by (namespace, pod) (kube_pod_container_resource_limits_cpu_cores))*0.9)
            for: 5m
            labels:
              severity: critical
            annotations:
              summary: "Kubernetes Pod Resources CPU Limits (instance {{ $labels.instance }})"
              description: "Pod {{ $labels.pod }} CPU limits has crossed 90%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

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

