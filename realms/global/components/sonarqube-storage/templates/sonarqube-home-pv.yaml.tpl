apiVersion: v1
kind: PersistentVolume
metadata:
  name: sonarqube-home-${realm}
spec:
  capacity:
    storage: 25Gi
  storageClassName: sonarqube-home
  azureDisk:
    kind: Managed
    diskName: sonarqube-${realm}
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/sonarqube-${realm}
    fsType: ext4
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
#  claimRef:
#    name: sonarqube-home-pvc
#    namespace: default