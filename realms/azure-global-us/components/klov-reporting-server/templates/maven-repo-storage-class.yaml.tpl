kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: maven-repo
provisioner: kubernetes.io/azure-file
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=1000
  - gid=1000
parameters:
  skuName: Standard_LRS