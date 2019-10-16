apiVersion: v1
kind: PersistentVolume
metadata:
  name: sonarqube-postgresql
spec:
  capacity:
    storage: 25Gi
  storageClassName: sonarqube-postgresql
  azureDisk:
    kind: Managed
    diskName: sonarqube-postgresql
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/sonarqube-postgresql
    fsType: ext4
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
#  claimRef:
#    name: sonarqube-postgresql-pvc
#    namespace: default