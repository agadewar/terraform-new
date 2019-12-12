apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-home
spec:
  capacity:
    storage: 10Gi
  storageClassName: jenkins
  azureDisk:
    kind: Managed
    diskName: jenkins-home
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/jenkins-home
    fsType: ext4
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
