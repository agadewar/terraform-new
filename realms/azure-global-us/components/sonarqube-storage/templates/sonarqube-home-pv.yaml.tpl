apiVersion: v1
kind: PersistentVolume
metadata:
  name: sonarqube-home
spec:
  capacity:
    storage: 25Gi
  storageClassName: sonarqube-home
  azureDisk:
    kind: Managed
    diskName: sonarqube-home
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/sonarqube-home
    fsType: ext4
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
#  claimRef:
#    name: sonarqube-home-pvc
#    namespace: default