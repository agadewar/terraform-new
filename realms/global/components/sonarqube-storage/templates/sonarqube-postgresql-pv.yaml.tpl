apiVersion: v1
kind: PersistentVolume
metadata:
  name: sonarqube-postgresql-${realm}
spec:
  capacity:
    storage: 25Gi
  storageClassName: sonarqube-postgresql
  azureDisk:
    kind: Managed
    diskName: sonarqube-${realm}
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/sonarqube-${realm}
    fsType: ext4
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
#  claimRef:
#    name: sonarqube-postgresql-pvc
#    namespace: default