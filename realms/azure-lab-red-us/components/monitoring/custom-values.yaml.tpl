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

grafana:
  storage:
      volumeClaimTemplate:
        spec:
          volumeMounts:
            - name: grafana-lab-us-red
              mountPath: 10.109.196.4:/grafana-lab-us-red
