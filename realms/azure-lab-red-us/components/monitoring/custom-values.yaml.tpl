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
              description: Pod {{ $labels.pod }} CPU limits has crossed 90%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}

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
