apiVersion: v1
kind: PersistentVolume
metadata:
  name: consul-home
spec:
  capacity:
    storage: 25Gi
  storageClassName: consul-home
  azureDisk:
    kind: Managed
    diskName: sonarqube-home
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/consul-home
    fsType: ext4
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
#  claimRef:
#    name: consul-home-pvc
#    namespace: default