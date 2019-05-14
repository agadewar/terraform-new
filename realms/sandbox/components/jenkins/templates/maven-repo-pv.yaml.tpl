# Using a template because azureDisk.kind cannot be used in Terraform

apiVersion: v1
kind: PersistentVolume
metadata:
  name: maven-repo-${realm}
spec:
  capacity:
    storage: 20Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: maven-repo
  azureFile: 
    secretName: "${secret_name}"
    shareName: maven-repo
#  azureDisk:
#    kind: Managed
#    diskName: maven-repo-${realm}
#    diskURI: /subscriptions/${subscription_id}/resourceGroups/${resource_group_name}/providers/Microsoft.Compute/disks/maven-repo-${realm}
#    fsType: ext4
#  claimRef:
#    name: maven-repo-pvc
#    namespace: default