apiVersion: v1
kind: PersistentVolume
metadata:
  name: jenkins-home-${realm}
spec:
  capacity:
    storage: 10Gi
  storageClassName: jenkins
  azureDisk:
    kind: Managed
    diskName: jenkins-home-${realm}
    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/jenkins-home-${realm}
    fsType: ext4
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
#  claimRef:
#    name: jenkins-home-pvc
#    namespace: default