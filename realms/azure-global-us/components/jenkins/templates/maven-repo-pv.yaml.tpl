# Using a template because azureDisk.kind cannot be used in Terraform

apiVersion: v1
kind: PersistentVolume
metadata:
  name: maven-repo
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
    shareName: jenkins-maven-repo
